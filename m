From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Tue, 01 Jul 2008 08:55:32 -0400
Message-ID: <200807011255.m61CtW6x003038@cmf.nrl.navy.mil>
References: <1214853492.10393.350.camel@pmac.infradead.org>
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:36361 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323AbYGAMzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 08:55:44 -0400
In-reply-to: <1214853492.10393.350.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1214853492.10393.350.camel@pmac.infradead.org>,David Woodhouse writes:
>True. But if you were to put the driver into an initrd, for example,

that is a pretty small number of people.  small enough that a physicist
would call it zero. regardless:

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index d5c1bbf..73338d2 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2562,7 +2562,8 @@ fore200e_load_and_start_fw(struct fore200e* fore200e)
     const struct firmware *firmware;
     struct device *device;
     struct fw_header *fw_header;
-    u32 *fw_data, fw_size;
+    const __le32 *fw_data;
+    u32 fw_size;
     u32 __iomem *load_addr;
     char buf[48];
     int err = -ENODEV;
@@ -2582,7 +2583,7 @@ fore200e_load_and_start_fw(struct fore200e* fore200e)
 	return err;
     }
 
-    fw_data = (u32 *) firmware->data;
+    fw_data = (__le32 *) firmware->data;
     fw_size = firmware->size / sizeof(u32);
     fw_header = (struct fw_header *) firmware->data;
     load_addr = fore200e->virt_base + le32_to_cpu(fw_header->load_offset);
@@ -3199,6 +3200,14 @@ static const struct fore200e_bus fore200e_bus[] = {
     {}
 };
 
-#ifdef MODULE_LICENSE
 MODULE_LICENSE("GPL");
+#ifdef CONFIG_PCI
+#ifdef __LITTLE_ENDIAN__
+MODULE_FIRMWARE("pca200e.bin");
+#else
+MODULE_FIRMWARE("pca200e_ecd.bin2");
+#endif
+#endif /* CONFIG_PCI */
+#ifdef CONFIG_SBUS
+MODULE_FIRMWARE("sba200e_ecd.bin2");
 #endif


