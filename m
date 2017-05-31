From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/9] nfp: move eBPF offload files to BPF app directory
Date: Wed, 31 May 2017 08:06:48 -0700
Message-ID: <20170531150651.16873-7-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35423 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdEaPLw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:52 -0400
Received: by mail-pg0-f50.google.com with SMTP id 8so9288670pgc.2
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:52 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pure move of eBPF offload files to BPF app directory,
only change the names and relative header location.
nfp_asm.h stays in the main dir and it doesn't really
have to include nfp_bpf.h.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile                         | 6 +++---
 drivers/net/ethernet/netronome/nfp/{nfp_bpf_jit.c => bpf/jit.c}     | 4 ++--
 drivers/net/ethernet/netronome/nfp/{nfp_bpf.h => bpf/main.h}        | 0
 .../net/ethernet/netronome/nfp/{nfp_net_offload.c => bpf/offload.c} | 6 +++---
 .../ethernet/netronome/nfp/{nfp_bpf_verifier.c => bpf/verifier.c}   | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h                        | 2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf_jit.c => bpf/jit.c} (99%)
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf.h => bpf/main.h} (100%)
 rename drivers/net/ethernet/netronome/nfp/{nfp_net_offload.c => bpf/offload.c} (99%)
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf_verifier.c => bpf/verifier.c} (99%)

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index bbbfc19e5887..5ad9a557f06a 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -21,17 +21,17 @@ nfp-objs := \
 	    nfp_main.o \
 	    nfp_net_common.o \
 	    nfp_net_ethtool.o \
-	    nfp_net_offload.o \
 	    nfp_net_main.o \
 	    nfp_netvf_main.o \
 	    nfp_port.o \
 	    bpf/main.o \
+	    bpf/offload.o \
 	    nic/main.o
 
 ifeq ($(CONFIG_BPF_SYSCALL),y)
 nfp-objs += \
-	    nfp_bpf_verifier.o \
-	    nfp_bpf_jit.o
+	    bpf/verifier.o \
+	    bpf/jit.o
 endif
 
 nfp-$(CONFIG_NFP_DEBUG) += nfp_net_debugfs.o
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
similarity index 99%
rename from drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
rename to drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 97a8f00674d0..8e57fda6b8b5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -39,8 +39,8 @@
 #include <linux/pkt_cls.h>
 #include <linux/unistd.h>
 
-#include "nfp_asm.h"
-#include "nfp_bpf.h"
+#include "main.h"
+#include "../nfp_asm.h"
 
 /* --- NFP prog --- */
 /* Foreach "multiple" entries macros provide pos and next<n> pointers.
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
similarity index 100%
rename from drivers/net/ethernet/netronome/nfp/nfp_bpf.h
rename to drivers/net/ethernet/netronome/nfp/bpf/main.h
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
similarity index 99%
rename from drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
rename to drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 2fa7b67d0c6f..30372dc99517 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -47,9 +47,9 @@
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
 
-#include "nfp_bpf.h"
-#include "nfp_net_ctrl.h"
-#include "nfp_net.h"
+#include "main.h"
+#include "../nfp_net_ctrl.h"
+#include "../nfp_net.h"
 
 void nfp_net_filter_stats_timer(unsigned long data)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
similarity index 99%
rename from drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
rename to drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index b3361f9b8e5c..d696ba46f70a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -38,7 +38,7 @@
 #include <linux/kernel.h>
 #include <linux/pkt_cls.h>
 
-#include "nfp_bpf.h"
+#include "main.h"
 
 /* Analyzer/verifier definitions */
 struct nfp_bpf_analyzer_priv {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index 22484b6fd3e8..d2b535739d2b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -34,7 +34,7 @@
 #ifndef __NFP_ASM_H__
 #define __NFP_ASM_H__ 1
 
-#include "nfp_bpf.h"
+#include <linux/types.h>
 
 #define REG_NONE	0
 
-- 
2.11.0
