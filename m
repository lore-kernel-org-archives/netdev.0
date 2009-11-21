From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 20/23] e1000e: do not error out on identification
	LED init failure
Date: Sat, 21 Nov 2009 01:27:59 -0800
Message-ID: <20091121092758.5715.48637.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:51131 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbZKUJ2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:28:09 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A failure to initialize the identification LED is not a fatal condition and
should allow the init path to continue.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    5 ++---
 drivers/net/e1000e/es2lan.c  |    5 ++---
 drivers/net/e1000e/ich8lan.c |    5 ++---
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index c5dc1b3..474f4e4 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -948,10 +948,9 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = e1000e_id_led_init(hw);
-	if (ret_val) {
+	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		return ret_val;
-	}
+		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 8a08956..6ba1228 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -803,10 +803,9 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = e1000e_id_led_init(hw);
-	if (ret_val) {
+	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		return ret_val;
-	}
+		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 2c1d08e..fe6dc3d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2722,10 +2722,9 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = mac->ops.id_led_init(hw);
-	if (ret_val) {
+	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		return ret_val;
-	}
+		/* This is not fatal and we should not stop init due to this */
 
 	/* Setup the receive address. */
 	e1000e_init_rx_addrs(hw, mac->rar_entry_count);

