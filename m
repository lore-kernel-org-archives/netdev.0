From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reboot Hangs When R8169 Loaded, Intel D945GCLF Atom Board With
	Anything in PCI Slot, 2.6.28-6 Vanilla Kernel  & Debian Etch
Date: Thu, 19 Feb 2009 00:50:06 +0100
Message-ID: <20090218235006.GA20512@electric-eye.fr.zoreil.com>
References: <499C8570.5080606@nscus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael Grollman <mgrollman@nscus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45612 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751706AbZBRXrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 18:47:41 -0500
Content-Disposition: inline
In-Reply-To: <499C8570.5080606@nscus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Grollman <mgrollman@nscus.com> :
[...]
> I do know truly that the r8169 module is the culprit, but since r8169  
> has fingerprints on the problem (see below), and I have had several  
> issues with the D945GCLF before for me with this driver, I figured might  
> as well start there, and report it as such.  If I am filing this in the  
> wrong place, please direct me to a better one.

Your report is fine. 

Can you send a complete 'dmesg' from boot before the problem happens
then try the patch below ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0771eb6..fe5b99c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3847,11 +3847,6 @@ out:
 	return 0;
 }
 
-static void rtl_shutdown(struct pci_dev *pdev)
-{
-	rtl8169_suspend(pdev, PMSG_SUSPEND);
-}
-
 #endif /* CONFIG_PM */
 
 static struct pci_driver rtl8169_pci_driver = {
@@ -3862,7 +3857,6 @@ static struct pci_driver rtl8169_pci_driver = {
 #ifdef CONFIG_PM
 	.suspend	= rtl8169_suspend,
 	.resume		= rtl8169_resume,
-	.shutdown	= rtl_shutdown,
 #endif
 };
 

-- 
Ueimor
