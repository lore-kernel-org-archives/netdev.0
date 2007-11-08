From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 02/05] r8169: do not enable the TBI for the 8168 and the
	81x0
Date: Fri, 9 Nov 2007 00:09:36 +0100
Message-ID: <20071108230936.GC15968@electric-eye.fr.zoreil.com>
References: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59776 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762483AbXKHXdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 18:33:45 -0500
Content-Disposition: inline
In-Reply-To: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 8168c and the 8100e choke on it. I have not seen an indication
nor received a report that the TBI is being actively used on the
remaining 8168b and 8110. Let's disable it for now until someone
complains.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Matthias Winkler <m.winkler@unicon-ka.de>
Cc: Maarten Vanraes <maarten.vanraes@gmail.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 702334e..9dbab3f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1741,7 +1741,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if (RTL_R8(PHYstatus) & TBI_Enable) {
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
-- 
1.5.3.3

