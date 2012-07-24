From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for
 loadbalancing too?
Date: Tue, 24 Jul 2012 18:42:20 +0200
Message-ID: <20120724164220.GA1721@minipsycho.orion>
References: <500EC5CF.3080400@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	andy@greyhouse.net
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46313 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab2GXQmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 12:42:25 -0400
Received: by weyx8 with SMTP id x8so5231976wey.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 09:42:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <500EC5CF.3080400@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 24, 2012 at 05:57:03PM CEST, chris.friesen@genband.com wrote:
>Hi all,
>
>We've been starting to look at bonding VFs from separate physical
>devices in a guest, but we've run into a problem.
>
>The host is bonding the corresponding PFs, and it uses arp
>monitoring.  What we have found is that any broadcast traffic from
>the guest (if they enable arp monitoring, for example) will be seen
>by the internal L2 switch of the NIC and sent up into the host, where
>the bonding driver will count it as incoming packets and use it to
>mark the link as good.
>
>The only solutions I've been able to come up with are:
>1) add arp validation for load balancing modes as well as active-backup.

This is my favourite.... No reason to not to turn arp validation on.
TEAM device (teamd arpping linkwatch) does arp or NSNA validation
always.

>2) put all the VMs in VLANs
>
>Anyone have any better ideas?
>
>Chris
>
>
>-- 
>
>Chris Friesen
>Software Designer
>
>3500 Carling Avenue
>Ottawa, Ontario K2H 8E9
>www.genband.com
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
