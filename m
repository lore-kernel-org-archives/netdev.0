From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 7/8] net: Rename TCA*BPF_DIGEST to ..._SHA256
Date: Tue, 10 Jan 2017 15:24:45 -0800
Message-ID: <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50784 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933192AbdAJXZE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 18:25:04 -0500
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it easier to add another digest algorithm down the road if
needed.  It also serves to force any programs that might have been
written against a kernel that had the old field name to notice the
change and make any necessary changes.

This shouldn't violate any stable API policies, as no released kernel
has ever had TCA*BPF_DIGEST.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/uapi/linux/pkt_cls.h       | 2 +-
 include/uapi/linux/tc_act/tc_bpf.h | 2 +-
 net/sched/act_bpf.c                | 2 +-
 net/sched/cls_bpf.c                | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index cb4bcdc58543..ac6b300c1550 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -397,7 +397,7 @@ enum {
 	TCA_BPF_NAME,
 	TCA_BPF_FLAGS,
 	TCA_BPF_FLAGS_GEN,
-	TCA_BPF_DIGEST,
+	TCA_BPF_SHA256,
 	__TCA_BPF_MAX,
 };
 
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index a6b88a6f7f71..eae18a7430eb 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -27,7 +27,7 @@ enum {
 	TCA_ACT_BPF_FD,
 	TCA_ACT_BPF_NAME,
 	TCA_ACT_BPF_PAD,
-	TCA_ACT_BPF_DIGEST,
+	TCA_ACT_BPF_SHA256,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1c60317f0121..3868a66d0b24 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -123,7 +123,7 @@ static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
-	nla = nla_reserve(skb, TCA_ACT_BPF_DIGEST,
+	nla = nla_reserve(skb, TCA_ACT_BPF_SHA256,
 			  sizeof(prog->filter->digest));
 	if (nla == NULL)
 		return -EMSGSIZE;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index adc776048d1a..6fc110321621 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -555,7 +555,7 @@ static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 	    nla_put_string(skb, TCA_BPF_NAME, prog->bpf_name))
 		return -EMSGSIZE;
 
-	nla = nla_reserve(skb, TCA_BPF_DIGEST, sizeof(prog->filter->digest));
+	nla = nla_reserve(skb, TCA_BPF_SHA256, sizeof(prog->filter->digest));
 	if (nla == NULL)
 		return -EMSGSIZE;
 
-- 
2.9.3
