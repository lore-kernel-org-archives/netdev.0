From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Thu,  2 Feb 2017 11:59:13 -0800
Message-ID: <1486065553-5074-1-git-send-email-u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34907 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdBBT7Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 14:59:24 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so2644478pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 11:59:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding a zero value to the packet pointer, the verifer
reports the following error:

R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=4) R2=pkt_end R3=fp-12 R4=imm4,min_value=4,max_value=4 R5=pkt(id=0,off=4,r=4) R6=ctx R7=imm0,min_value=0,max_value=0 R8=inv,min_value=0,max_value=0 R9=inv R10=fp
269: (bf) r2 = r0
270: (77) r2 >>= 3
271: (bf) r4 = r1
272: (0f) r4 += r2
addition of negative constant to packet pointer is not allowed

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index fb3513b..1a754e5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1397,7 +1397,7 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		imm = insn->imm;
 
 add_imm:
-		if (imm <= 0) {
+		if (imm < 0) {
 			verbose("addition of negative constant to packet pointer is not allowed\n");
 			return -EACCES;
 		}
-- 
2.7.4
