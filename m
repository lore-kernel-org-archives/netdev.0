From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] ibm_emac: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:59:16 +0200
Message-ID: <20070205165916.GK3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: ebs@ebshome.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932662AbXBEQ7d@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch to use ARRAY_SIZE macro already defined in kernel.h.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
Patch isn't compile-tested cause I don't have the needed hardware.

diff --git a/drivers/net/ibm_emac/ibm_emac_debug.c b/drivers/net/ibm_emac/ibm_emac_debug.c
index 92f970d..1f70906 100644
--- a/drivers/net/ibm_emac/ibm_emac_debug.c
+++ b/drivers/net/ibm_emac/ibm_emac_debug.c
@@ -132,7 +132,7 @@ void emac_dbg_register(int idx, struct ocp_enet_private *dev)
 {
 	unsigned long flags;
 
-	if (idx >= sizeof(__emacs) / sizeof(__emacs[0])) {
+	if (idx >= ARRAY_SIZE(__emacs)) {
 		printk(KERN_WARNING
 		       "invalid index %d when registering EMAC for debugging\n",
 		       idx);
@@ -148,7 +148,7 @@ void mal_dbg_register(int idx, struct ibm_ocp_mal *mal)
 {
 	unsigned long flags;
 
-	if (idx >= sizeof(__mals) / sizeof(__mals[0])) {
+	if (idx >= ARRAY_SIZE(__mals)) {
 		printk(KERN_WARNING
 		       "invalid index %d when registering MAL for debugging\n",
 		       idx);
@@ -167,11 +167,11 @@ void emac_dbg_dump_all(void)
 
 	local_irq_save(flags);
 
-	for (i = 0; i < sizeof(__mals) / sizeof(__mals[0]); ++i)
+	for (i = 0; i < ARRAY_SIZE(__mals); ++i)
 		if (__mals[i])
 			emac_mal_dump(__mals[i]);
 
-	for (i = 0; i < sizeof(__emacs) / sizeof(__emacs[0]); ++i)
+	for (i = 0; i < ARRAY_SIZE(__emacs); ++i)
 		if (__emacs[i])
 			emac_mac_dump(i, __emacs[i]);
 

-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
