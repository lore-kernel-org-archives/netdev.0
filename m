From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 03/12] bpf/verifier: more concise register state
 logs for constant var_off
Date: Mon, 7 Aug 2017 15:26:56 +0100
Message-ID: <eb0a7a2d-9b24-b000-28ff-181521712ed1@solarflare.com>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 7557800..08a6fa0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -234,25 +234,33 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				verbose(",ks=%d,vs=%d",
 					reg->map_ptr->key_size,
 					reg->map_ptr->value_size);
-			if (reg->smin_value != reg->umin_value &&
-			    reg->smin_value != S64_MIN)
-				verbose(",smin_value=%lld",
-					(long long)reg->smin_value);
-			if (reg->smax_value != reg->umax_value &&
-			    reg->smax_value != S64_MAX)
-				verbose(",smax_value=%lld",
-					(long long)reg->smax_value);
-			if (reg->umin_value != 0)
-				verbose(",umin_value=%llu",
-					(unsigned long long)reg->umin_value);
-			if (reg->umax_value != U64_MAX)
-				verbose(",umax_value=%llu",
-					(unsigned long long)reg->umax_value);
-			if (!tnum_is_unknown(reg->var_off)) {
-				char tn_buf[48];
-
-				tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-				verbose(",var_off=%s", tn_buf);
+			if (tnum_is_const(reg->var_off)) {
+				/* Typically an immediate SCALAR_VALUE, but
+				 * could be a pointer whose offset is too big
+				 * for reg->off
+				 */
+				verbose(",imm=%llx", reg->var_off.value);
+			} else {
+				if (reg->smin_value != reg->umin_value &&
+				    reg->smin_value != S64_MIN)
+					verbose(",smin_value=%lld",
+						(long long)reg->smin_value);
+				if (reg->smax_value != reg->umax_value &&
+				    reg->smax_value != S64_MAX)
+					verbose(",smax_value=%lld",
+						(long long)reg->smax_value);
+				if (reg->umin_value != 0)
+					verbose(",umin_value=%llu",
+						(unsigned long long)reg->umin_value);
+				if (reg->umax_value != U64_MAX)
+					verbose(",umax_value=%llu",
+						(unsigned long long)reg->umax_value);
+				if (!tnum_is_unknown(reg->var_off)) {
+					char tn_buf[48];
+
+					tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
+					verbose(",var_off=%s", tn_buf);
+				}
 			}
 			verbose(")");
 		}
