From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/5] bonding: Refactor, fix, and updates
Date: Wed,  2 Jul 2008 18:21:57 -0700
Message-ID: <12150481222323-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:51920 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbYGCBWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:05 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631M58f008566
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631M4Ll232872
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:04 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M4BY004106
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
