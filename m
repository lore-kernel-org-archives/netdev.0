From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] MIPS,bpf: fix missing break in switch statement
Date: Tue, 22 Aug 2017 23:46:06 +0100
Message-ID: <20170822224606.6273-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34468 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdHVWqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 18:46:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

There is a missing break causing a fall-through and setting
ctx.use_bbit_insns to the wrong value. Fix this by adding the
missing break.

Detected with cppcheck:
"Variable 'ctx.use_bbit_insns' is reassigned a value before the old
one has been used. 'break;' missing?"

Fixes: 8d8d18c3283f ("MIPS,bpf: Fix using smp_processor_id() in preemptible splat.")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
Acked-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/ebpf_jit.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/mips/net/ebpf_jit.c b/arch/mips/net/ebpf_jit.c
index 44ddc12cbb0e..7646891c4e9b 100644
--- a/arch/mips/net/ebpf_jit.c
+++ b/arch/mips/net/ebpf_jit.c
@@ -1892,6 +1892,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	case CPU_CAVIUM_OCTEON2:
 	case CPU_CAVIUM_OCTEON3:
 		ctx.use_bbit_insns = 1;
+		break;
 	default:
 		ctx.use_bbit_insns = 0;
 	}
-- 
2.14.1
