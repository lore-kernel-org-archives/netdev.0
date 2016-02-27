From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] rocker: fix an error code
Date: Sat, 27 Feb 2016 14:31:43 +0300
Message-ID: <20160227113143.GA19177@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Ying Xue <ying.xue@windriver.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We intended to return PTR_ERR() here instead of 1.

Fixes: 1f9993f6825f ('rocker: fix a neigh entry leak issue')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
We recently moved rocker files around so this only applies to -next.
Probably returning the wrong error code is harmless.

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 099008a..07218c3 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1449,7 +1449,7 @@ static int ofdpa_port_ipv4_resolve(struct ofdpa_port *ofdpa_port,
 	if (!n) {
 		n = neigh_create(&arp_tbl, &ip_addr, dev);
 		if (IS_ERR(n))
-			return IS_ERR(n);
+			return PTR_ERR(n);
 	}
 
 	/* If the neigh is already resolved, then go ahead and
