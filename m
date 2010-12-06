From: Joe Jin <joe.jin@oracle.com>
Subject: [patch 1/1] driver/net/benet: fix be_cmd_multicast_set() memcpy bug
Date: Mon, 6 Dec 2010 21:00:59 +0800
Message-ID: <20101206130059.GA19448@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg.marsden@oracle.com, guru.anbalagane@oracle.com,
	joe.jin@oracle.com
To: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

Regarding  benet be_cmd_multicast_set() function, now using
netdev_for_each_mc_addr() helper for mac address copy, but
when copying to req->mac[] did not increase of the index.

Cc: Sathya Perla <sathyap@serverengines.com>
Cc: Subbu Seetharaman <subbus@serverengines.com>
Cc: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Cc: Ajit Khaparde <ajitk@serverengines.com>
Signed-off-by: Joe Jin <joe.jin@oracle.com>

---
 be_cmds.c |    2 +-

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 36eca1c..e4465d2 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1235,7 +1235,7 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 
 		i = 0;
 		netdev_for_each_mc_addr(ha, netdev)
-			memcpy(req->mac[i].byte, ha->addr, ETH_ALEN);
+			memcpy(req->mac[i++].byte, ha->addr, ETH_ALEN);
 	} else {
 		req->promiscuous = 1;
 	}


-- 
Oracle <http://www.oracle.com>
Joe Jin | Team Leader, Software Development | +8610.8278.6295
ORACLE | Linux and Virtualization
Incubator Building 2-A ZPark | Beijing China, 100094
