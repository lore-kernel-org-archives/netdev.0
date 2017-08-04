From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: comment fixes against BPF devmap helper calls
Date: Thu, 03 Aug 2017 21:58:22 -0700
Message-ID: <20170804045822.1032.43840.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34268 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdHDE6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 00:58:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id t86so773174pfe.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 21:58:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update BPF comments to accurately reflect XDP usage.

Fixes: 97f91a7cf04ff ("bpf: add bpf_redirect_map helper routine")
Reported-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/uapi/linux/bpf.h |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1106a8c..1ae061e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -345,14 +345,20 @@ enum bpf_attach_type {
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
  *     @ifindex: ifindex of the net device
- *     @flags: bit 0 - if set, redirect to ingress instead of egress
- *             other bits - reserved
- *     Return: TC_ACT_REDIRECT
- * int bpf_redirect_map(key, map, flags)
+ *     @flags:
+ *	  cls_bpf:
+ *          bit 0 - if set, redirect to ingress instead of egress
+ *          other bits - reserved
+ *	  xdp_bpf:
+ *	    all bits - reserved
+ *     Return: cls_bpf: TC_ACT_REDIRECT
+ *	       xdp_bfp: XDP_REDIRECT
+ * int bpf_redirect_map(map, key, flags)
  *     redirect to endpoint in map
+ *     @map: pointer to dev map
  *     @key: index in map to lookup
- *     @map: fd of map to do lookup in
  *     @flags: --
+ *     Return: XDP_REDIRECT on success or XDP_ABORT on error
  *
  * u32 bpf_get_route_realm(skb)
  *     retrieve a dst's tclassid
