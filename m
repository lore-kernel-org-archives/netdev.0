From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 3/6] MIPS: net: BPF: Fix stack pointer allocation
Date: Thu, 4 Jun 2015 11:56:13 +0100
Message-ID: <1433415376-20952-4-git-send-email-markos.chandras@imgtec.com>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix stack pointer offset which could potentially corrupt
argument registers in the previous frame. The calculated offset
reflects the size of all the registers we need to preserve so there
is no need for this erroneous subtraction.

Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 56e0e8e9674d..84cd09ba230a 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -676,11 +676,7 @@ static unsigned int get_stack_depth(struct jit_ctx *ctx)
 		sp_off += config_enabled(CONFIG_64BIT) ?
 			(ARGS_USED_BY_JIT + 1) * SZREG : SZREG;
 
-	/*
-	 * Subtract the bytes for the last registers since we only care about
-	 * the location on the stack pointer.
-	 */
-	return sp_off - SZREG;
+	return sp_off;
 }
 
 static void build_prologue(struct jit_ctx *ctx)
-- 
2.4.2
