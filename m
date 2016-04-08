From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 1/3] tc, bpf: add new csum and tunnel signatures
Date: Sat,  9 Apr 2016 00:32:03 +0200
Message-ID: <db0c345315f783fb7f289f37d392375bcf6f0b16.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39613 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758975AbcDHWcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:32:19 -0400
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new signatures for BPF_FUNC_csum_diff, BPF_FUNC_skb_get_tunnel_opt
and BPF_FUNC_skb_set_tunnel_opt.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/bpf_api.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/bpf_api.h b/include/bpf_api.h
index 4b16d25..0f278f0 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -212,6 +212,8 @@ static int BPF_FUNC(l3_csum_replace, struct __sk_buff *skb, uint32_t off,
 		    uint32_t from, uint32_t to, uint32_t flags);
 static int BPF_FUNC(l4_csum_replace, struct __sk_buff *skb, uint32_t off,
 		    uint32_t from, uint32_t to, uint32_t flags);
+static int BPF_FUNC(csum_diff, const void *from, uint32_t from_size,
+		    const void *to, uint32_t to_size, uint32_t seed);
 
 /* Packet vlan encap/decap */
 static int BPF_FUNC(skb_vlan_push, struct __sk_buff *skb, uint16_t proto,
@@ -225,6 +227,11 @@ static int BPF_FUNC(skb_set_tunnel_key, struct __sk_buff *skb,
 		    const struct bpf_tunnel_key *from, uint32_t size,
 		    uint32_t flags);
 
+static int BPF_FUNC(skb_get_tunnel_opt, struct __sk_buff *skb,
+		    void *to, uint32_t size);
+static int BPF_FUNC(skb_set_tunnel_opt, struct __sk_buff *skb,
+		    const void *from, uint32_t size);
+
 /** LLVM built-ins, mem*() routines work for constant size */
 
 #ifndef lock_xadd
-- 
1.9.3
