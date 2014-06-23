From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 06/17] MIPS: bpf: Use 'andi' instead of 'and' for the VLAN cases
Date: Mon, 23 Jun 2014 10:38:49 +0100
Message-ID: <1403516340-22997-7-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:60852 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbaFWJjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:31 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VLAN_VID_MASK and VLAN_TAG_PRESENT are immediates, so using
'and' which expects 3 registers will produce wrong results. Fix
this by using the 'andi' instruction.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 95728ea6cb74..fe5041bdc6fb 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1317,9 +1317,9 @@ jmp_cmp:
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit_half_load(r_s0, r_skb, off, ctx);
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				emit_and(r_A, r_s0, VLAN_VID_MASK, ctx);
+				emit_andi(r_A, r_s0, VLAN_VID_MASK, ctx);
 			else
-				emit_and(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
+				emit_andi(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
 			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			off = pkt_type_offset();
-- 
2.0.0
