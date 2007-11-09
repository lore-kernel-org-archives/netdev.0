From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SIS190.c
Date: Sat, 10 Nov 2007 00:45:07 +0100
Message-ID: <20071109234507.GA4196@electric-eye.fr.zoreil.com>
References: <327198.23103.qm@web57010.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, drnlmuller+bugs@gmail.com,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: j gleacher <jgleacher@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42149 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763887AbXKIXp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 18:45:28 -0500
Content-Disposition: inline
In-Reply-To: <327198.23103.qm@web57010.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

j gleacher <jgleacher@yahoo.com> :
[sorry for the delay, I was busy]
> I'm not sure how to properly send you this information about subject,
> but with a new Acer Desktop I needed to add 0x0968 to the below to
> get the eth0 recognized.

Ok. Can you check the patch below against 2.6.24-rc2 ?

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..51bbb60 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1549,28 +1549,31 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 }
 
 /**
- *	sis190_get_mac_addr_from_apc - Get MAC address for SiS965 model
+ *	sis190_get_mac_addr_from_apc - Get MAC address for SiS96x model
  *	@pdev: PCI device
  *	@dev:  network device to get address for
  *
- *	SiS965 model, use APC CMOS RAM to store MAC address.
+ *	SiS96x model, use APC CMOS RAM to store MAC address.
  *	APC CMOS RAM is accessed through ISA bridge.
  *	MAC address is read into @net_dev->dev_addr.
  */
 static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						  struct net_device *dev)
 {
+	static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
 	struct pci_dev *isa_bridge;
 	u8 reg, tmp8;
-	int i;
+	unsigned int i;
 
 	net_probe(tp, KERN_INFO "%s: Read MAC address from APC.\n",
 		  pci_name(pdev));
 
-	isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0965, NULL);
-	if (!isa_bridge)
-		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0966, NULL);
+	for (i = 0; i < ARRAY_SIZE(ids); i++) {
+		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, ids[i], NULL);
+		if (isa_bridge)
+			break;
+	}
 
 	if (!isa_bridge) {
 		net_probe(tp, KERN_INFO "%s: Can not find ISA bridge.\n",

> While this enables the interface, the performance is horrible as my
> wlan0 if much faster and eth0 frequently hangs.  I'm learning about
> drivers, so I could help if there is a need to troubleshoot this type
> of issue. 

"hangs" == no network or no computer ?

Please send:
- a complete dmesg (from boot to poor behavior)
- the output of lspci -vvvxxxx
- the output of mii-diag -v ethX
- the content of /proc/interrupts

-- 
Ueimor
