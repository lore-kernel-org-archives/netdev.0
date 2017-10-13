From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] cxgb4: fix missing break in switch and indent return statements
Date: Fri, 13 Oct 2017 17:29:00 +0100
Message-ID: <20171013162900.16911-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ganesh Goudar <ganeshgr@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The break statement for the Macronix case is missing and will
fall through to the Winbond case and re-assign the size setting.
Fix this by adding the missing break statement.  Also correctly
indent the return statements.

Detected by CoverityScan, CID#1458020 ("Missing break in switch")

Fixes: 96ac18f14a5a ("cxgb4: Add support for new flash parts")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index b3fd1f457639..fe7db70a9fa6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8289,7 +8289,7 @@ static int t4_get_flash_params(struct adapter *adap)
 		default:
 			dev_err(adap->pdev_dev, "Micron Flash Part has bad size, ID = %#x, Density code = %#x\n",
 				flashid, density);
-		return -EINVAL;
+			return -EINVAL;
 		}
 		break;
 	}
@@ -8308,8 +8308,9 @@ static int t4_get_flash_params(struct adapter *adap)
 		default:
 			dev_err(adap->pdev_dev, "Macronix Flash Part has bad size, ID = %#x, Density code = %#x\n",
 				flashid, density);
-		return -EINVAL;
+			return -EINVAL;
 		}
+		break;
 	}
 	case 0xef: { /* Winbond */
 		/* This Density -> Size decoding table is taken from Winbond
@@ -8326,7 +8327,7 @@ static int t4_get_flash_params(struct adapter *adap)
 		default:
 			dev_err(adap->pdev_dev, "Winbond Flash Part has bad size, ID = %#x, Density code = %#x\n",
 				flashid, density);
-		return -EINVAL;
+			return -EINVAL;
 		}
 		break;
 	}
-- 
2.14.1
