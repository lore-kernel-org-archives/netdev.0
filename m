From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] bonding: add more netlink attributes
Date: Sat, 14 Dec 2013 01:08:36 -0500 (EST)
Message-ID: <20131214.010836.1667099923747304358.davem@davemloft.net>
References: <20131212214558.21629.92365.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab3LNGIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:08:40 -0500
In-Reply-To: <20131212214558.21629.92365.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Thu, 12 Dec 2013 14:09:48 -0800

> v2:
> 
> Addressed v1 review comments.  In particular, Jay's concern about
> current sysfs ordering limitations carrying over to iproute.  Netlink
> attributes are processed in a priority order in
> bond_netlink.c:bond_changelink().  Lower priority attributes can't undo
> higher priority attributes when attempting to set both with iproute
> command.  For example, this command will fail:
> 
>   ip link add bond1 type bond mode active-backup miimon 10 arp_interval 10
> 
> Because we're trying to create a new bond to use incompatible miimon
> and ARP interval attributes.  However, if attributes are applied
> one-at-a-time, previously applied attributes can be overridden:
> 
>   ip link add bond1 type bond mode active-backup miimon 10
>   ip link set dev bond1 type bond arp_interval 10
> 
> These two commands succeed.  The bond is first created to use miimon.
> Next, the bond is converted to use ARP interval, which undoes miimon.
> 
> v1:
> 
> Following Jiri Pirko's lead, add more bonding netlink attributes.  Sending
> matching iproute2 patch separately.  sysfs access to attributes is
> retained.

Series applied, thanks Scott.
