From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/14] nfp: separate high level and low level NSP headers
Date: Tue,  4 Apr 2017 16:12:30 -0700
Message-ID: <20170404231235.32027-10-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34638 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755303AbdDDXNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:01 -0400
Received: by mail-pf0-f172.google.com with SMTP id 197so13821763pfv.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:01 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon add more NSP commands and structure definitions.
Move all high-level NSP header contents to a common nfp_nsp.h file.
Right now it mostly boils down to renaming nfp_nsp_eth.h and
moving some functions from nfp.h there.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c         |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c   |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c  |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c     |  2 +-
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h      | 12 ++----------
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c  |  1 +
 .../nfp/nfpcore/{nfp_nsp_eth.h => nfp_nsp.h}          | 19 ++++++++++++++-----
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c  |  2 +-
 8 files changed, 22 insertions(+), 20 deletions(-)
 rename drivers/net/ethernet/netronome/nfp/nfpcore/{nfp_nsp_eth.h => nfp_nsp.h} (89%)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 96266796fd09..bea2a1a6c211 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -48,7 +48,7 @@
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
 #include "nfpcore/nfp_nffw.h"
-#include "nfpcore/nfp_nsp_eth.h"
+#include "nfpcore/nfp_nsp.h"
 
 #include "nfpcore/nfp6000_pcie.h"
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 8664815f45ce..e2197160e4dc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -67,7 +67,7 @@
 #include <net/pkt_cls.h>
 #include <net/vxlan.h>
 
-#include "nfpcore/nfp_nsp_eth.h"
+#include "nfpcore/nfp_nsp.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3b2a09821a59..963d6dd97cec 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -49,7 +49,7 @@
 #include <linux/ethtool.h>
 
 #include "nfpcore/nfp.h"
-#include "nfpcore/nfp_nsp_eth.h"
+#include "nfpcore/nfp_nsp.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 8e975c36877c..3e1f97e88710 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -52,7 +52,7 @@
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
 #include "nfpcore/nfp_nffw.h"
-#include "nfpcore/nfp_nsp_eth.h"
+#include "nfpcore/nfp_nsp.h"
 #include "nfpcore/nfp6000_pcie.h"
 
 #include "nfp_net_ctrl.h"
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index f7ca8e374923..778bd9424d5d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -48,18 +48,10 @@
 
 const char *nfp_hwinfo_lookup(struct nfp_cpp *cpp, const char *lookup);
 
-/* Implemented in nfp_nsp.c */
+/* Implemented in nfp_nsp.c, low level functions */
 
 struct nfp_nsp;
-struct firmware;
-
-struct nfp_nsp *nfp_nsp_open(struct nfp_cpp *cpp);
-void nfp_nsp_close(struct nfp_nsp *state);
-u16 nfp_nsp_get_abi_ver_major(struct nfp_nsp *state);
-u16 nfp_nsp_get_abi_ver_minor(struct nfp_nsp *state);
-int nfp_nsp_wait(struct nfp_nsp *state);
-int nfp_nsp_device_soft_reset(struct nfp_nsp *state);
-int nfp_nsp_load_fw(struct nfp_nsp *state, const struct firmware *fw);
+
 int nfp_nsp_read_eth_table(struct nfp_nsp *state, void *buf, unsigned int size);
 int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 			    const void *buf, unsigned int size);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 17822ae4a17f..6482831282b2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -49,6 +49,7 @@
 
 #include "nfp.h"
 #include "nfp_cpp.h"
+#include "nfp_nsp.h"
 
 /* Offsets relative to the CSR base */
 #define NSP_STATUS		0x00
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
similarity index 89%
rename from drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
rename to drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
index 57eb3cfa6a0a..e3baec3cccc2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
@@ -31,12 +31,24 @@
  * SOFTWARE.
  */
 
-#ifndef NSP_NSP_ETH_H
-#define NSP_NSP_ETH_H 1
+#ifndef NSP_NSP_H
+#define NSP_NSP_H 1
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
+struct firmware;
+struct nfp_cpp;
+struct nfp_nsp;
+
+struct nfp_nsp *nfp_nsp_open(struct nfp_cpp *cpp);
+void nfp_nsp_close(struct nfp_nsp *state);
+u16 nfp_nsp_get_abi_ver_major(struct nfp_nsp *state);
+u16 nfp_nsp_get_abi_ver_minor(struct nfp_nsp *state);
+int nfp_nsp_wait(struct nfp_nsp *state);
+int nfp_nsp_device_soft_reset(struct nfp_nsp *state);
+int nfp_nsp_load_fw(struct nfp_nsp *state, const struct firmware *fw);
+
 enum nfp_eth_interface {
 	NFP_INTERFACE_NONE	= 0,
 	NFP_INTERFACE_SFP	= 1,
@@ -119,9 +131,6 @@ struct nfp_eth_table {
 	} ports[0];
 };
 
-struct nfp_cpp;
-struct nfp_nsp;
-
 struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp);
 struct nfp_eth_table *
 __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 07b4ded01514..837de15ed720 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -43,7 +43,7 @@
 #include <linux/module.h>
 
 #include "nfp.h"
-#include "nfp_nsp_eth.h"
+#include "nfp_nsp.h"
 #include "nfp6000/nfp6000.h"
 
 #define NSP_ETH_NBI_PORT_COUNT		24
-- 
2.11.0
