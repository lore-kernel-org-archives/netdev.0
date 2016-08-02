From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1122/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:23 +0800
Message-ID: <20160802121823.24923-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/netfilter/nf_conntrack_ftp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 19efeba..5bc9e90 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -43,10 +43,10 @@ static DEFINE_SPINLOCK(nf_ftp_lock);
 #define MAX_PORTS 8
 static u_int16_t ports[MAX_PORTS];
 static unsigned int ports_c;
-module_param_array(ports, ushort, &ports_c, 0400);
+module_param_array(ports, ushort, &ports_c, S_IRUSR);
 
 static bool loose;
-module_param(loose, bool, 0600);
+module_param(loose, bool, S_IRUSR | S_IWUSR);
 
 unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
-- 
2.9.2

