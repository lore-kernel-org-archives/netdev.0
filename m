From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 07/17] MIPS: bpf: Add SEEN_SKB to flags when looking for the PKT_TYPE
Date: Mon, 23 Jun 2014 10:38:50 +0100
Message-ID: <1403516340-22997-8-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:44439 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbaFWJjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:32 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SKF_AD_PKTTYPE uses the skb pointer so make sure it's in the
flags so it will be initialized in time.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index fe5041bdc6fb..8cae27af03da 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1322,6 +1322,8 @@ jmp_cmp:
 				emit_andi(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
 			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
+			ctx->flags |= SEEN_SKB;
+
 			off = pkt_type_offset();
 
 			if (off < 0)
-- 
2.0.0
