From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch iproute2] iplink: add support for bonding netlink
Date: Tue, 29 Oct 2013 19:00:20 +0000 (UTC)
Message-ID: <loom.20131029T194706-188@post.gmane.org>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us> <1382111401-1233-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45708 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040Ab3J2TFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 15:05:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VbEb9-0006nh-S5
	for netdev@vger.kernel.org; Tue, 29 Oct 2013 20:05:04 +0100
Received: from static-50-53-129-139.bvtn.or.frontiernet.net ([50.53.129.139])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 20:05:03 +0100
Received: from sfeldma by static-50-53-129-139.bvtn.or.frontiernet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 20:05:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri <at> resnulli.us> writes:

> +		} else if (matches(*argv, "active_slave") == 0) {
> +			NEXT_ARG();
> +			ifindex = if_nametoindex(*argv);
> +			if (!ifindex)
> +				return -1;
> +			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, ifindex);
> +		} else if (matches(*argv, "clear_active_slave") == 0) {
> +			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, 0);

How do active_slave and clear_active_slave work from the ip link cmd line 
when bond is added, but doesn't have any slaves yet?  I did:

  ip link add bond1 type bond mode 1
  ip link set dev eth1 master bond1
  ip link set dev eth2 master bond1

Then tried:

  ip link add bond1 type bond active_slave eth1
  RTNETLINK answers: File exists

Or:

  ip link set dev bond1 active_slave eth1
  Error: either "dev" is duplicate, or "active_slave" is a garbage.

I must be dense but I can't figure how you can set active_slave before 
slaves have been added to bond, or even after slaves have been added 
to bond.

> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 8b68c78..1825dc5 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
>  <at>  <at>  -51,6 +51,7  <at>  <at>  ip-link \- network device configuration
>  .ti -8
>  .IR TYPE " := [ "
>  .BR bridge " | "
> +.BR bond " ]"

That should be " | "?

With patch applied, the man page shows:

       TYPE := [ bridge | bond ] can | dummy | ifb | ipoib | macvlan | ...

-scott
