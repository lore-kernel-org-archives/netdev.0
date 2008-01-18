From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/7] bonding: 7 fixes for 2.6.24
Date: Thu, 17 Jan 2008 16:24:56 -0800
Message-ID: <12006159033257-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:43755 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbYARAZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:12 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0P7qv020800
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:07 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0P7BX129170
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:07 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0P6F9021806
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Following are seven patches to fix locking problems,
silence locking-related warnings and resolve one recent regression
in the current 2.6.24-rc.

	The first three patches are reposts, the rest are new.

	patch 1: fix locking in sysfs primary/active selection

	Call core network functions with expected locks to
eliminate potential deadlock and silence warnings.

	patch 2: fix ASSERT_RTNL that produces spurious warnings

	Relocate ASSERT_RTNL to remove a false warning; after patch,
ASSERT is located in code that holds only RTNL (additional locks were
causing the ASSERT to trip)

	patch 3: fix locking during alb failover and slave removal

	Fix all call paths into alb_fasten_mac_swap to hold only RTNL.
Eliminates potential deadlock and silences warnings.

	patch 4: release slaves when master removed via sysfs

	Insure that all slaves are removed when bond is destroyed via
sysfs.

	patch 5: Fix up parameter parsing

	Recent changes broke parameter parsing; this fixes things.

	patch 6: Fix lock ordering for rtnl and bonding_rwsem

	Resolves some lockdep warnings related to ordering between
rtnl and bonding_rwsem.

	patch 7: Don't hold lock when calling rtnl_unlock

	Since rtnl_unlock can sleep, don't hold any other locks when
calling it.

	Patches are against the current netdev-2.6#upstream branch.

	Please apply for 2.6.24.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
