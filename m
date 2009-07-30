From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding ALB sends bogus packets
Date: Thu, 30 Jul 2009 13:28:19 -0700
Message-ID: <22132.1248985699@death.nxdomain.ibm.com>
References: <20090730130656.680e9152@nehalam>
Cc: Ben Greear <greearb@candelatech.com>, bonding-devel@lists.sf.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52119 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbZG3U2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:28:21 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6UKQXf2015350
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 14:26:33 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6UKSKQa128638
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 14:28:20 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6UKSHWx028550
	for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 14:28:20 -0600
In-reply-to: <20090730130656.680e9152@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>The bonding ALB mode builds packets with type, ETH_P_LOOP.
>
>Well ETH_P_LOOP is defined as 0x0060 which looks completely bogus.
>All Ethernet types less than 1536 are interpreted as 802.2 frames.
>The result is that the resulting packet looks like a bogus 802.2
>frame to the other host (or switch).  I have no idea what the 
>initial design was or what the purpose of this code is, but it
>should either send a real packet or nothing at all.

	I've looked at that code before, too, although I hadn't noticed
that ETH_P_LOOP is under the limit for interpretation as a length
instead of a type.

	I believe the purpose of the code is to update the switch's MAC
address table for the port and insure it's correct, since the alb mode
can move MAC addresses around amongst the set of slaves.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
