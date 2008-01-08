From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Mon,  7 Jan 2008 17:56:57 -0800
Message-ID: <11997574203125-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:39276 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012AbYAHB5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 20:57:05 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m081v3eo001826
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:03 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m081v3d0105296
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:03 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m081v2Ht022323
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Following are three fixes to fix locking problems and
silence locking-related warnings in the current 2.6.24-rc.

	patch 1: fix locking in sysfs primary/active selection

	Call core network functions with expected locks to
eliminate potential deadlock and silence warnings.

	patch 2: fix ASSERT_RTNL that produces spurious warnings

	Relocate ASSERT_RTNL to remove a false warning; after patch,
ASSERT is located in code that holds only RTNL (additional locks were
causing the ASSERT to trip)

	patch 3: fix locking during alb failover and slave removal

	Fix all call paths into alb_fasten_mac_swap to hold only RTNL.
Eliminates deadlock and silences warnings.

	Patches are against the current netdev-2.6#upstream branch.

	Please apply for 2.6.24.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
