From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 2/2] e1000e: display a warning message when SmartSpeed works
Date: Wed, 16 Jan 2013 11:23:20 +0900
Message-ID: <50F60F18.2030108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:37538 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757015Ab3APCXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 21:23:22 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CD67A3EE0BB
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:23:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6E9245DE55
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:23:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C37345DE5C
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:23:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88792E08019
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:23:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E012E08008
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:23:21 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current e1000e driver doesn't tell nothing when Link Speed is downgraded due to
SmartSpeed.  As a result, users suspect that there is something wrong with
NIC.  If the cause of it is SmartSpeed, there is no means to replace NIC. This
patch make e1000e notify users that SmartSpeed worked.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 337644d..1c416fc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4435,6 +4435,13 @@ static void e1000_watchdog_task(struct work_struct *work)
 						   &adapter->link_speed,
 						   &adapter->link_duplex);
 			e1000_print_link_info(adapter);
+
+			/* check if SmartSpeed worked */
+			e1000e_check_downshift(hw);
+			if (phy->speed_downgraded)
+				netdev_warn(netdev, "Link Speed was "
+					"downgraded by SmartSpeed\n");
+
 			/* On supported PHYs, check for duplex mismatch only
 			 * if link has autonegotiated at 10/100 half
 			 */
