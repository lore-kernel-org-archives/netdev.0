From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 09/17] MIPS: bpf: Use correct mask for VLAN_TAG case
Date: Mon, 23 Jun 2014 10:38:52 +0100
Message-ID: <1403516340-22997-10-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:15007 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbaFWJje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:34 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using VLAN_VID_MASK is not correct to get the vlan tag. Use
~VLAN_PRESENT_MASK instead and make sure it's u16 so the top 16-bits
will be removed. This will ensure that the emit_andi() code will not
treat this as a big 32-bit unsigned value.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 500f97fdc0e1..a4d1b76e7373 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1317,7 +1317,7 @@ jmp_cmp:
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit_half_load(r_s0, r_skb, off, ctx);
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				emit_andi(r_A, r_s0, VLAN_VID_MASK, ctx);
+				emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
 			else
 				emit_andi(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
 			break;
-- 
2.0.0
