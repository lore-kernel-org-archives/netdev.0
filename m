From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/12] nfp: bpf: support BPF offload only on little endian
Date: Thu, 12 Oct 2017 10:34:13 -0700
Message-ID: <20171012173418.4029-8-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:54662 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbdJLRey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:54 -0400
Received: by mail-pf0-f179.google.com with SMTP id m28so5826798pfi.11
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:54 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eBPF is host-endian specific.  Translating both BE and LE eBPF
to the NFP is feasible, but would require quite a bit of indirection.
The fact that I don't have access to any BE hosts that would fit
a 25G/40G/100G NIC is also limiting my ability to test big endian.

For now restrict the offload to little endian hosts only.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 074726980994..6e74f8db1cc1 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -42,9 +42,11 @@
 
 static bool nfp_net_ebpf_capable(struct nfp_net *nn)
 {
+#ifdef __LITTLE_ENDIAN
 	if (nn->cap & NFP_NET_CFG_CTRL_BPF &&
 	    nn_readb(nn, NFP_NET_CFG_BPF_ABI) == NFP_NET_BPF_ABI)
 		return true;
+#endif
 	return false;
 }
 
-- 
2.14.1
