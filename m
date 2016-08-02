From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1130/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:02 +0800
Message-ID: <20160802121902.25452-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/netfilter/xt_recent.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index d725a27..271f4ef 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -48,9 +48,9 @@ static unsigned int ip_list_hash_size __read_mostly;
 static unsigned int ip_list_perms __read_mostly = 0644;
 static unsigned int ip_list_uid __read_mostly;
 static unsigned int ip_list_gid __read_mostly;
-module_param(ip_list_tot, uint, 0400);
-module_param(ip_list_hash_size, uint, 0400);
-module_param(ip_list_perms, uint, 0400);
+module_param(ip_list_tot, uint, S_IRUSR);
+module_param(ip_list_hash_size, uint, S_IRUSR);
+module_param(ip_list_perms, uint, S_IRUSR);
 module_param(ip_list_uid, uint, S_IRUGO | S_IWUSR);
 module_param(ip_list_gid, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(ip_list_tot, "number of IPs to remember per list");
@@ -61,7 +61,7 @@ MODULE_PARM_DESC(ip_list_gid, "default owning group of /proc/net/xt_recent/* fil
 
 /* retained for backwards compatibility */
 static unsigned int ip_pkt_list_tot __read_mostly;
-module_param(ip_pkt_list_tot, uint, 0400);
+module_param(ip_pkt_list_tot, uint, S_IRUSR);
 MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP address to remember (max. 255)");
 
 #define XT_RECENT_MAX_NSTAMPS	256
-- 
2.9.2
