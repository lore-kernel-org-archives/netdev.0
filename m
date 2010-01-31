From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 6/7] atm: Use for_each_bit
Date: Sun, 31 Jan 2010 20:53:29 +0900
Message-ID: <1264938810-4173-6-git-send-email-akinobu.mita@gmail.com>
References: <1264938810-4173-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753175Ab0AaL5a@vger.kernel.org>
In-Reply-To: <1264938810-4173-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/atm/lanai.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index cf97c34..97700f8 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -306,11 +306,10 @@ static void vci_bitfield_iterate(struct lanai_dev *lanai,
 	const unsigned long *lp,
 	void (*func)(struct lanai_dev *,vci_t vci))
 {
-	vci_t vci = find_first_bit(lp, NUM_VCI);
-	while (vci < NUM_VCI) {
+	vci_t vci;
+
+	for_each_bit(vci, lp, NUM_VCI)
 		func(lanai, vci);
-		vci = find_next_bit(lp, NUM_VCI, vci + 1);
-	}
 }
 
 /* -------------------- BUFFER  UTILITIES: */
-- 
1.6.0.6
