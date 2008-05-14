From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/2] bonding: ARP monitor changes
Date: Tue, 13 May 2008 18:17:55 -0700
Message-ID: <12107278773938-git-send-email-fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49762 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbYENBSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 21:18:00 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4E1Enl4022439
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 21:14:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4E1Hx0W195800
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 19:17:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4E1HxEo010208
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 19:17:59 -0600
Received: from localhost.localdomain (wecm-9-67-94-236.wecm.ibm.com [9.67.94.236])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m4E1HwWZ010192
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 19:17:59 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Two patches for bonding; these apply to net-next-2.6.  I'm
particularly interested in comments and test reports on #1.

	1- Refactor ARP monitor for active-backup mode.  Split the current
monolithic function into three: inspection, commit, and probe.  Done
primarily to get RTNL semantics right for next patch.  That could have
been done via conditional locking (as miimon was), but this feels like a
cleaner solution.

	2- Add a "follow" option to fail_over_mac.  This causes the
bonding master to take the MAC of the first slave, but not program the
other slaves with that MAC address.  During failover, the MAC moves to the
new currently active slave.  For multiport devices that can't handle
having all ports set to the same MAC (but still want the benefits of the
bond's MAC not changing during failover).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
