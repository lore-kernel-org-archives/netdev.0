From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next] samples/bpf: Fix compilation issue in redirect dummy program
Date: Thu, 31 Aug 2017 14:16:39 +0300
Message-ID: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38330 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750884AbdHaLRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 07:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compilation error below:

$ make samples/bpf/

LLVM ERROR: 'xdp_redirect_dummy' label emitted multiple times to
assembly file
make[1]: *** [samples/bpf/xdp_redirect_kern.o] Error 1
make: *** [samples/bpf/] Error 2

Fixes: 306da4e685b4 ("samples/bpf: xdp_redirect load XDP dummy prog on TX device")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 samples/bpf/xdp_redirect_kern.c     | 2 +-
 samples/bpf/xdp_redirect_map_kern.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/xdp_redirect_kern.c b/samples/bpf/xdp_redirect_kern.c
index 1c90288d0203..8abb151e385f 100644
--- a/samples/bpf/xdp_redirect_kern.c
+++ b/samples/bpf/xdp_redirect_kern.c
@@ -82,7 +82,7 @@ int xdp_redirect_prog(struct xdp_md *ctx)
 
 /* Redirect require an XDP bpf_prog loaded on the TX device */
 SEC("xdp_redirect_dummy")
-int xdp_redirect_dummy(struct xdp_md *ctx)
+int xdp_redirect_dummy_prog(struct xdp_md *ctx)
 {
 	return XDP_PASS;
 }
diff --git a/samples/bpf/xdp_redirect_map_kern.c b/samples/bpf/xdp_redirect_map_kern.c
index 79795d41ad0d..740a529ba84f 100644
--- a/samples/bpf/xdp_redirect_map_kern.c
+++ b/samples/bpf/xdp_redirect_map_kern.c
@@ -84,7 +84,7 @@ int xdp_redirect_map_prog(struct xdp_md *ctx)
 
 /* Redirect require an XDP bpf_prog loaded on the TX device */
 SEC("xdp_redirect_dummy")
-int xdp_redirect_dummy(struct xdp_md *ctx)
+int xdp_redirect_dummy_prog(struct xdp_md *ctx)
 {
 	return XDP_PASS;
 }
-- 
1.8.3.1
