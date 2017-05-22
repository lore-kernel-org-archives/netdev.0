From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 09:07:46 -0500
Message-ID: <20170522140746.GA10113@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.122]:44879 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933798AbdEVOI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 10:08:27 -0400
Received: from cm1.websitewelcome.com (cm.websitewelcome.com [192.185.0.102])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id C222E11DC99
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 09:07:48 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Execution cannot reach NET_IP_ALIGN inside the following statement:
ip_align = strict ? 2 : NET_IP_ALIGN

Addresses-Coverity-ID: 1409762
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
NOTE: variable ip_align could also be removed and use value 2 directly.

 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1eddb71..94f6e46 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -812,7 +812,7 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 	 * we force this to 2 which is universally what architectures use
 	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
 	 */
-	ip_align = strict ? 2 : NET_IP_ALIGN;
+	ip_align = 2;
 	if ((ip_align + reg_off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
 			ip_align, reg_off, off, size);
-- 
2.5.0
