From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 8/9] atm: Use for_each_set_bit
Date: Tue,  2 Feb 2010 00:10:39 +0900
Message-ID: <1265037040-23413-8-git-send-email-akinobu.mita@gmail.com>
References: <1265037040-23413-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265037040-23413-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2: rename for_each_bit to for_each_set_bit

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/atm/lanai.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index cf97c34..dbffe8f 100644
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
+	for_each_set_bit(vci, lp, NUM_VCI)
 		func(lanai, vci);
-		vci = find_next_bit(lp, NUM_VCI, vci + 1);
-	}
 }
 
 /* -------------------- BUFFER  UTILITIES: */
-- 
1.6.0.6
