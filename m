From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH] net: cassini: use nested lock annotation
Date: Fri,  9 May 2014 01:07:17 +0200
Message-ID: <1399590437-5548-1-git-send-email-emilgoode@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Arend van Spriel <arend@broadcom.com>,
	Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the cas_lock_tx function we acquire multiple locks in a loop and
need to use nested lock annotation to prevent lockdep warnings.

Reported-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: Emil Goode <emilgoode@gmail.com>
---
 drivers/net/ethernet/sun/cassini.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index df8d383..b9ac20f 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -246,7 +246,7 @@ static inline void cas_lock_tx(struct cas *cp)
 	int i;
 
 	for (i = 0; i < N_TX_RINGS; i++)
-		spin_lock(&cp->tx_lock[i]);
+		spin_lock_nested(&cp->tx_lock[i], i);
 }
 
 static inline void cas_lock_all(struct cas *cp)
-- 
1.7.10.4
