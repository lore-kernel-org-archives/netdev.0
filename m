From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1108/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:15 +0800
Message-ID: <20160802121715.23997-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38103 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965971AbcHBNAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 09:00:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/ipv6/af_inet6.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bfa86f0..aca076e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -83,13 +83,13 @@ struct ipv6_params ipv6_defaults = {
 
 static int disable_ipv6_mod;
 
-module_param_named(disable, disable_ipv6_mod, int, 0444);
+module_param_named(disable, disable_ipv6_mod, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(disable, "Disable IPv6 module such that it is non-functional");
 
-module_param_named(disable_ipv6, ipv6_defaults.disable_ipv6, int, 0444);
+module_param_named(disable_ipv6, ipv6_defaults.disable_ipv6, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
 
-module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
+module_param_named(autoconf, ipv6_defaults.autoconf, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all interfaces");
 
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
-- 
2.9.2
