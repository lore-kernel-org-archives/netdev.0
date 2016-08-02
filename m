From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1127/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:47 +0800
Message-ID: <20160802121847.25254-1-baolex.ni@intel.com>
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
 net/netfilter/nf_conntrack_sip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index f72ba55..a34046e 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -37,20 +37,20 @@ MODULE_ALIAS_NFCT_HELPER("sip");
 #define MAX_PORTS	8
 static unsigned short ports[MAX_PORTS];
 static unsigned int ports_c;
-module_param_array(ports, ushort, &ports_c, 0400);
+module_param_array(ports, ushort, &ports_c, S_IRUSR);
 MODULE_PARM_DESC(ports, "port numbers of SIP servers");
 
 static unsigned int sip_timeout __read_mostly = SIP_TIMEOUT;
-module_param(sip_timeout, uint, 0600);
+module_param(sip_timeout, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(sip_timeout, "timeout for the master SIP session");
 
 static int sip_direct_signalling __read_mostly = 1;
-module_param(sip_direct_signalling, int, 0600);
+module_param(sip_direct_signalling, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(sip_direct_signalling, "expect incoming calls from registrar "
 					"only (default 1)");
 
 static int sip_direct_media __read_mostly = 1;
-module_param(sip_direct_media, int, 0600);
+module_param(sip_direct_media, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(sip_direct_media, "Expect Media streams between signalling "
 				   "endpoints only (default 1)");
 
-- 
2.9.2
