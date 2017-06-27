From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/14] nfp: flower: add Kconfig for flower app
Date: Tue, 27 Jun 2017 00:50:28 -0700
Message-ID: <20170627075028.4009-15-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35220 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdF0HvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:18 -0400
Received: by mail-pf0-f179.google.com with SMTP id c73so12616388pfk.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:18 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Give users an option not to build the flower-offload related code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/Kconfig       | 10 ++++++++++
 drivers/net/ethernet/netronome/nfp/Makefile  |  8 ++++++--
 drivers/net/ethernet/netronome/nfp/nfp_app.c |  2 ++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/Kconfig b/drivers/net/ethernet/netronome/Kconfig
index 0d5a7b9203a4..0e331e2f685a 100644
--- a/drivers/net/ethernet/netronome/Kconfig
+++ b/drivers/net/ethernet/netronome/Kconfig
@@ -25,6 +25,16 @@ config NFP
 	  cards working as a advanced Ethernet NIC.  It works with both
 	  SR-IOV physical and virtual functions.
 
+config NFP_APP_FLOWER
+	bool "NFP4000/NFP6000 TC Flower offload support"
+	depends on NFP
+	depends on NET_SWITCHDEV
+	---help---
+	  Enable driver support for TC Flower offload on NFP4000 and NFP6000.
+	  Say Y, if you are planning to make use of TC Flower offload
+	  either directly, with Open vSwitch, or any other way.  Note that
+	  TC Flower offload requires specific FW to work.
+
 config NFP_DEBUG
 	bool "Debug support for Netronome(R) NFP4000/NFP6000 NIC drivers"
 	depends on NFP
diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 10b556b2c59d..43bdbc228969 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -27,10 +27,14 @@ nfp-objs := \
 	    nfp_port.o \
 	    bpf/main.o \
 	    bpf/offload.o \
-	    flower/cmsg.o \
-	    flower/main.o \
 	    nic/main.o
 
+ifeq ($(CONFIG_NFP_APP_FLOWER),y)
+nfp-objs += \
+	    flower/cmsg.o \
+	    flower/main.o
+endif
+
 ifeq ($(CONFIG_BPF_SYSCALL),y)
 nfp-objs += \
 	    bpf/verifier.o \
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 5620de05c996..c704c022574f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -43,7 +43,9 @@
 static const struct nfp_app_type *apps[] = {
 	&app_nic,
 	&app_bpf,
+#ifdef CONFIG_NFP_APP_FLOWER
 	&app_flower,
+#endif
 };
 
 const char *nfp_app_mip_name(struct nfp_app *app)
-- 
2.11.0
