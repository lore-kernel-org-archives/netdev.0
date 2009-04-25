From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Fri, 24 Apr 2009 17:31:03 -0700
Message-ID: <30658.1240619463@death.nxdomain.ibm.com>
References: <49F1DE6F.1030606@trash.net> <49F1EB2F.1050505@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54238 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbZDYAbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 20:31:00 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3P0TR2V020718
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 18:29:27 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3P0UxGf086978
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 18:30:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3P0Uw4x008182
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 18:30:59 -0600
In-reply-to: <49F1EB2F.1050505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> wrote:

>Suppose that someone has eth0, eth0.2 and eth0.5 admin UP.
>
>Then, sets eth0.5 admin DOWN.
>
>Later they set eth0 down and up for some reason.
>
>Would eth0.5 now go admin UP?

	Yes, with the patch applied, it does.

>If so, I think that is not a good idea and could possibly be considered
>a security issue.  I think instead there should be a new flag for VLANs
>that is 'preferred-admin-state'.  To be UP, both the underlying device
>and the preferred state must be UP.  That should allow bouncing eth0
>w/out affecting the eventual admin state of the VLANs on eth0 in
>the example above.

	I dunno if it's a security issue, but I'd agree it's wrong.  I
looked, and I suspect that a couple of judiciously placed "if
(dev->flags & IFF_UP)" bits ought to sort things out by simply not
copying the carrier state to the upper level VLAN device if that device
is down.  Unless somebody works this up over the weekend, I'll work that
out on Monday.

	When the vlan device (eth0.5 in the above example) later is set
up, it'll do the right thing for its own carrier state.

>For what it's worth, it seems that other virtual devices, such as VIFS
>on a wifi radio, might need the same sort of behaviour.

	Would they actually need a flag, or could it be worked out just
by checking their IFF_UP-ness?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


