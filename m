From: Bernd Faust <berndfaust@gmail.com>
Subject: [PATCH] e1000e: fix timing for 82579 Gigabit Ethernet controller
Date: Thu, 16 Feb 2017 19:42:07 +0100
Message-ID: <1487270527-4549-1-git-send-email-berndfaust@gmail.com>
Cc: Bernd Faust <berndfaust@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Yanir Lubetkin <yanirx.lubetkin@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32872 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933578AbdBPSmU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:42:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After an upgrade to Linux kernel v4.x the hardware timestamps of the
82579 Gigabit Ethernet Controller are different than expected.
The values that are being read are almost four times as big as before
the kernel upgrade.

The difference is that after the upgrade the driver sets the clock
frequency to 25MHz, where before the upgrade it was set to 96MHz. Intel
confirmed that the correct frequency for this network adapter is 96MHz.

Signed-off-by: Bernd Faust <berndfaust@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7017281..8b7113d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3511,6 +3511,12 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca)

 	switch (hw->mac.type) {
 	case e1000_pch2lan:
+		/* Stable 96MHz frequency */
+		incperiod = INCPERIOD_96MHz;
+		incvalue = INCVALUE_96MHz;
+		shift = INCVALUE_SHIFT_96MHz;
+		adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHz;
+		break;
 	case e1000_pch_lpt:
 		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
 			/* Stable 96MHz frequency */
