From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 0/5] bonding: Refactor, fix, and updates
Date: Wed, 06 Aug 2008 15:49:10 -0700
Message-ID: <2476.1218062950@death>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49609 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271AbYHFWtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 18:49:14 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m76MnDvC001463
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2008 18:49:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m76MnDqm182920
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2008 16:49:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m76MnCc4003477
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2008 16:49:13 -0600
In-reply-to: <12150481222323-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Jeff, are you still waiting for net-next-2.6 to settle before
forwarding patches?  It's been a couple of weeks since your last status
update, and I want check to see if I should resend the patches from this
series.

	Davem did ack the relevant patches.

From: Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6 0/5] bonding: Refactor, fix, and updates
Date: 	Wed,  2 Jul 2008 18:21:57 -0700

	Five patches for bonding; these apply to net-next-2.6.

	Patch 1 is a refactor of the MII monitor, similar to the previous
refactor of the ARP active-backup monitor.  It replaces the monolithic
monitor function that uses conditional locking with a two phase (inspect
and commit) approach with strict locking (RTNL) required only for the
commit phase (which is only called when things actually change).  The long
term goal here is to ultimately consolidate all monitors within a generic
framework.

	Patch 2 makes a change to the Infiniband slave removal processing
to avoid a system crash when removing the final slave via sysfs.

	Patches 3 - 5 provide support for allowing slaves to receive
traffic independently from the master, and require some explanation.

	The goal of the last three patches is to permit slaves to receive
incoming traffic independently from the master; there are legitimate
reasons for wanting to do so, e.g., LLDP.  There are two ways to implement
this: a special case within bonding (skb_bond_should_drop) that would
require a hard-coded list of protocols to pass through, or a generic
method, that modifies the packet receive logic within netif_receive_skb.
The latter method is what is presented here.

	Please apply patches 1 - 2, and review and apply or provide
feedback for patches 3 - 5.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
