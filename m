From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] Add Wake on LAN support to sis900 (2)
Date: Fri, 24 Feb 2006 11:03:54 +0100
Message-ID: <5698750A-4231-4500-B060-B06165E5C0FD@brownhat.org>
References: <200601050223.k052Ngu2003866@hera.kernel.org> <20060224025759.GA14027@redhat.com>
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-8--740522272
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932176AbWBXKE1@vger.kernel.org>
In-Reply-To: <20060224025759.GA14027@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail-8--740522272
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

Attached you find the patch that fixes two bugs in the WoL  
implementation of sis900. The first causes hangs on some system on  
driver load, the second causes troubles when disabling WoL support.  
Both fixes are one liner and really simple. Patch is against latest  
netdev-2.6 tree.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Daniele Venzano <venza@brownhat.org>


--Apple-Mail-8--740522272
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="sis900_wol_fix.diff"
Content-Disposition: attachment;
	filename=sis900_wol_fix.diff

--- new/drivers/net/sis900.c.old	2006-02-24 10:46:06.000000000 +0100
+++ new/drivers/net/sis900.c	2006-02-24 09:57:57.000000000 +0100
@@ -540,7 +540,7 @@ static int __devinit sis900_probe(struct
 	printk("%2.2x.\n", net_dev->dev_addr[i]);
 
 	/* Detect Wake on Lan support */
-	ret = inl(CFGPMC & PMESP);
+	ret = (inl(net_dev->base_addr + CFGPMC) & PMESP) >> 27;
 	if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
 		printk(KERN_INFO "%s: Wake on LAN only available from suspend to RAM.", net_dev->name);
 
@@ -2040,7 +2040,7 @@ static int sis900_set_wol(struct net_dev
 
 	if (wol->wolopts == 0) {
 		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
-		cfgpmcsr |= ~PME_EN;
+		cfgpmcsr &= ~PME_EN;
 		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
 		outl(pmctrl_bits, pmctrl_addr);
 		if (netif_msg_wol(sis_priv))

--Apple-Mail-8--740522272--
