From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net PATCH] bpf: fix samples xdp_tx_iptunnel and tc_l2_redirect
 with fake KBUILD_MODNAME
Date: Wed, 18 Jan 2017 17:19:00 +0100
Message-ID: <148475634058.19645.17347886661194782120.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>, kafai@fb.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754070AbdARQo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 11:44:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix build errors for samples/bpf xdp_tx_iptunnel and tc_l2_redirect,
when dynamic debugging is enabled (CONFIG_DYNAMIC_DEBUG) by defining a
fake KBUILD_MODNAME.

Just like Daniel Borkmann fixed other samples/bpf in commit
96a8eb1eeed2 ("bpf: fix samples to add fake KBUILD_MODNAME").

Fixes: 12d8bb64e3f6 ("bpf: xdp: Add XDP example for head adjustment")
Fixes: 90e02896f1a4 ("bpf: Add test for bpf_redirect to ipip/ip6tnl")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/tc_l2_redirect_kern.c  |    1 +
 samples/bpf/xdp_tx_iptunnel_kern.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/samples/bpf/tc_l2_redirect_kern.c b/samples/bpf/tc_l2_redirect_kern.c
index 92a44729dbe4..7ef2a12b25b2 100644
--- a/samples/bpf/tc_l2_redirect_kern.c
+++ b/samples/bpf/tc_l2_redirect_kern.c
@@ -4,6 +4,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <uapi/linux/bpf.h>
 #include <uapi/linux/if_ether.h>
 #include <uapi/linux/if_packet.h>
diff --git a/samples/bpf/xdp_tx_iptunnel_kern.c b/samples/bpf/xdp_tx_iptunnel_kern.c
index 85c38ecd3a2d..0f4f6e8c8611 100644
--- a/samples/bpf/xdp_tx_iptunnel_kern.c
+++ b/samples/bpf/xdp_tx_iptunnel_kern.c
@@ -8,6 +8,7 @@
  * encapsulating the incoming packet in an IPv4/v6 header
  * and then XDP_TX it out.
  */
+#define KBUILD_MODNAME "foo"
 #include <uapi/linux/bpf.h>
 #include <linux/in.h>
 #include <linux/if_ether.h>
