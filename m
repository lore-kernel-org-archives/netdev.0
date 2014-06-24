From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH 1/2] powerpc: bpf: Use correct mask while accessing the VLAN tag
Date: Tue, 24 Jun 2014 13:59:28 +0400
Message-ID: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:54631 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbaFXKYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 06:24:21 -0400
Received: by mail-lb0-f173.google.com with SMTP id s7so113154lbd.18
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 03:24:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the proper mask which is 0xefff
---
 arch/powerpc/net/bpf_jit_comp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 6dcdade..af0ed4d 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -393,7 +393,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
+				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
 			else
 				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
 			break;
-- 
2.0.0
