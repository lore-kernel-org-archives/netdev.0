From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: bpf: zero extend 4 byte context loads
Date: Wed, 28 Sep 2016 23:47:37 +0100
Message-ID: <1475102857-23672-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38882 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752507AbcI1Wrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 18:47:49 -0400
Received: by mail-wm0-f45.google.com with SMTP id l132so97336170wmf.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 15:47:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set upper 32 bits of destination register to zeros after
load from the context structure.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index 3de819acd68c..f8df5300f49c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -1134,6 +1134,8 @@ static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	else
 		return -ENOTSUPP;
 
+	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
+
 	return 0;
 }
 
-- 
1.9.1
