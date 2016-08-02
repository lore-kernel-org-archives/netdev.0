From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0754/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:05 +0800
Message-ID: <20160802114305.32385-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jbenc@redhat.com, tgraf@suug.ch,
	hannes@stressinduktion.org, daniel@iogearbox.net,
	pabeni@redhat.com, chuansheng.liu@intel.com, baolex.ni@intel.com
To: mst@redhat.com, f.fainelli@gmail.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27073 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934153AbcHBMUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:20:46 -0400
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
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f999db2..ffc540f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -63,11 +63,11 @@
  * for compatibility with early adopters.
  */
 static unsigned short vxlan_port __read_mostly = 8472;
-module_param_named(udp_port, vxlan_port, ushort, 0444);
+module_param_named(udp_port, vxlan_port, ushort, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
 
 static bool log_ecn_error = true;
-module_param(log_ecn_error, bool, 0644);
+module_param(log_ecn_error, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static int vxlan_net_id;
-- 
2.9.2
