From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] [SIS190] Constify data marked as __devinitdata
Date: Wed, 30 Jan 2008 12:23:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
References: <1201690388-9052-1-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33672 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbYA3LXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 06:23:24 -0500
In-Reply-To: <1201690388-9052-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 30 2008 11:53, Jonas Bonn wrote:
>
>This fixes build error as gcc complains about a "section type conflict"
>due to the const __devinitdata in sis190_get_mac_addr_from_apc().

>-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
>+static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
> 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
> 	{ 0, },

Eh? Did you mean to

-        static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
+        static u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };

instead? Because AFAIK, const *and* __sectionmarker does not mix.
