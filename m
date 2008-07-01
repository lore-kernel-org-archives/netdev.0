From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: How come realtek drivers are combined
Date: Tue, 1 Jul 2008 23:58:06 +0200
Message-ID: <20080701215806.GA804@electric-eye.fr.zoreil.com>
References: <4864235A.40807@dell.com> <20080627191835.GA5064@electric-eye.fr.zoreil.com> <4868FA94.7060500@dell.com> <20080630213102.GB24253@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34323 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751872AbYGAV6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 17:58:21 -0400
Content-Disposition: inline
In-Reply-To: <20080630213102.GB24253@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Mario Limonciello <mario_limonciello@dell.com> :
[...]
> > Now I did see a fair deal of patches floating in from you, so I'll clone
> > your netdev git tree and give this a run on some of the RTL8101's that
> > are having trouble.
> 
> Don't expect miracle: the 8101/8102 part is not floating yet.

That being said, you can give a try to the version of the day at
http://userweb.kernel.org/~romieu/r8169/2.6.26-rc6/ and apply the
patch below to it:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8d18bb6..860a472 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2547,8 +2547,13 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
+		int cap;
+
+		cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+		if (cap != 0) {
+			pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL,
+					      PCI_EXP_DEVCTL_NOSNOOP_EN);
+		}
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);

-- 
Ueimor
