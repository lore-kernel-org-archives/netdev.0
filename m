From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 21/26] igb: remove disable_av variable from mac_info
	struct
Date: Sat, 07 Feb 2009 01:21:51 -0800
Message-ID: <20090207092151.15697.25102.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:34647
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756089AbZBGJWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:22:12 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The disable_av variable is never used by the driver and provides no value as
it is likely a leftover debugging variable.  I have removed it and replaced
the one spot that checked for it with a check for a valid address.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_hw.h  |    1 -
 drivers/net/igb/e1000_mac.c |    3 ++-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 62ccd49..6d1564f 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -484,7 +484,6 @@ struct e1000_mac_info {
 	bool asf_firmware_present;
 	bool autoneg;
 	bool autoneg_failed;
-	bool disable_av;
 	bool disable_hw_init_bits;
 	bool get_link_status;
 	bool ifs_params_forced;
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 6682206..e5d23e0 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -200,7 +200,8 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 
 	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
 
-	if (!hw->mac.disable_av)
+	/* If MAC address zero, no need to set the AV bit */
+	if (rar_low || rar_high)
 		rar_high |= E1000_RAH_AV;
 
 	wr32(E1000_RAL(index), rar_low);

