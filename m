From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 15/15] nfp: bpf: pass dst register to ld_field instruction
Date: Sun,  8 Oct 2017 21:04:17 -0700
Message-ID: <20171009040417.22172-16-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:46233 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdJIEF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:59 -0400
Received: by mail-pf0-f169.google.com with SMTP id p87so3485351pfj.3
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:59 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ld_field instruction is a bit special because the encoding uses
two source registers and one of them becomes the output.  We do
need to pass the dst register to our encoding helpers though,
otherwise the "write both banks" flag will not be observed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index f68052367db7..13148f30fc4c 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -408,7 +408,8 @@ emit_ld_field_any(struct nfp_prog *nfp_prog, enum shf_sc sc, u8 shift,
 	struct nfp_insn_re_regs reg;
 	int err;
 
-	err = swreg_to_restricted(reg_none(), dst, src, &reg, true);
+	/* Note: ld_field is special as it uses one of the src regs as dst */
+	err = swreg_to_restricted(dst, dst, src, &reg, true);
 	if (err) {
 		nfp_prog->error = err;
 		return;
-- 
2.14.1
