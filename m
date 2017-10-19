From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net 5/5] net/ncsi: Fix length of GVI response packet
Date: Thu, 19 Oct 2017 13:43:09 +1100
Message-ID: <20171019024309.13628-5-sam@mendozajonas.com>
References: <20171019024309.13628-1-sam@mendozajonas.com>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org,
        Samuel Mendoza-Jonas <sam@mendozajonas.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gavin Shan <gwshan@linux.vnet.ibm.com>

The length of GVI (GetVersionInfo) response packet should be 40 instead
of 36. This issue was found from /sys/kernel/debug/ncsi/eth0/stats.

 # ethtool --ncsi eth0 swstats
     :
 RESPONSE     OK       TIMEOUT  ERROR
 =======================================
 GVI          0        0        2

With this applied, no error reported on GVI response packets:

 # ethtool --ncsi eth0 swstats
     :
 RESPONSE     OK       TIMEOUT  ERROR
 =======================================
 GVI          2        0        0

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/ncsi-rsp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 265b9a892d41..927dad4759d1 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -959,7 +959,7 @@ static struct ncsi_rsp_handler {
 	{ NCSI_PKT_RSP_EGMF,    4, ncsi_rsp_handler_egmf    },
 	{ NCSI_PKT_RSP_DGMF,    4, ncsi_rsp_handler_dgmf    },
 	{ NCSI_PKT_RSP_SNFC,    4, ncsi_rsp_handler_snfc    },
-	{ NCSI_PKT_RSP_GVI,    36, ncsi_rsp_handler_gvi     },
+	{ NCSI_PKT_RSP_GVI,    40, ncsi_rsp_handler_gvi     },
 	{ NCSI_PKT_RSP_GC,     32, ncsi_rsp_handler_gc      },
 	{ NCSI_PKT_RSP_GP,     -1, ncsi_rsp_handler_gp      },
 	{ NCSI_PKT_RSP_GCPS,  172, ncsi_rsp_handler_gcps    },
-- 
2.14.2
