From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/12] nfp: bpf: reorder arguments to emit_ld_field_any()
Date: Thu, 12 Oct 2017 10:34:08 -0700
Message-ID: <20171012173418.4029-3-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:51199 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdJLReu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:50 -0400
Received: by mail-pf0-f180.google.com with SMTP id m63so5837602pfk.7
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:50 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ld_field instruction has the following format in NFP assembler:

  ld_field[dst, 1000, src, <<24]

reoder parameters to emit_ld_field_any() to make it closer to
the familiar assembler order.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 13148f30fc4c..cf8a6eb3ec99 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -402,8 +402,8 @@ __emit_ld_field(struct nfp_prog *nfp_prog, enum shf_sc sc,
 }
 
 static void
-emit_ld_field_any(struct nfp_prog *nfp_prog, enum shf_sc sc, u8 shift,
-		  swreg dst, u8 bmask, swreg src, bool zero)
+emit_ld_field_any(struct nfp_prog *nfp_prog, swreg dst, u8 bmask, swreg src,
+		  enum shf_sc sc, u8 shift, bool zero)
 {
 	struct nfp_insn_re_regs reg;
 	int err;
@@ -424,7 +424,7 @@ static void
 emit_ld_field(struct nfp_prog *nfp_prog, swreg dst, u8 bmask, swreg src,
 	      enum shf_sc sc, u8 shift)
 {
-	emit_ld_field_any(nfp_prog, sc, shift, dst, bmask, src, false);
+	emit_ld_field_any(nfp_prog, dst, bmask, src, sc, shift, false);
 }
 
 static void emit_nop(struct nfp_prog *nfp_prog)
-- 
2.14.1
