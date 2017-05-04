From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute] tc: Reflect HW offload status
Date: Thu,  4 May 2017 16:15:15 +0300
Message-ID: <1493903715-29664-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36854 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752803AbdEDNP0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 09:15:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using "both" policy (where none
of skip_sw or skip_hw flags are set by user-space).

Add two new flags, "in hw" and "not in hw" such that user
space can determine if a filter is actually offloaded to
hw or not. The "in hw" UAPI semantics was chosen so it's
similar to the "skip hw" flag logic.

If none of these two flags are set, this signals running
over older kernel.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 tc/f_bpf.c      | 5 +++++
 tc/f_flower.c   | 5 +++++
 tc/f_matchall.c | 5 +++++
 tc/f_u32.c      | 5 +++++
 4 files changed, 20 insertions(+)

diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index df8a259..75c44c0 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -210,6 +210,11 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 			fprintf(f, "skip_hw ");
 		if (flags & TCA_CLS_FLAGS_SKIP_SW)
 			fprintf(f, "skip_sw ");
+
+		if (flags & TCA_CLS_FLAGS_IN_HW)
+			fprintf(f, "in_hw ");
+		else if (flags & TCA_CLS_FLAGS_NOT_IN_HW)
+			fprintf(f, "not_in_hw ");
 	}
 
 	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN])
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5aac4a0..ebc63ca 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -1171,6 +1171,11 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			fprintf(f, "\n  skip_hw");
 		if (flags & TCA_CLS_FLAGS_SKIP_SW)
 			fprintf(f, "\n  skip_sw");
+
+		if (flags & TCA_CLS_FLAGS_IN_HW)
+			fprintf(f, "\n  in_hw");
+		else if (flags & TCA_CLS_FLAGS_NOT_IN_HW)
+			fprintf(f, "\n  not_in_hw");
 	}
 
 	if (tb[TCA_FLOWER_ACT])
diff --git a/tc/f_matchall.c b/tc/f_matchall.c
index ac48630..5a51e75 100644
--- a/tc/f_matchall.c
+++ b/tc/f_matchall.c
@@ -137,6 +137,11 @@ static int matchall_print_opt(struct filter_util *qu, FILE *f,
 			fprintf(f, "\n  skip_hw");
 		if (flags & TCA_CLS_FLAGS_SKIP_SW)
 			fprintf(f, "\n  skip_sw");
+
+		if (flags & TCA_CLS_FLAGS_IN_HW)
+			fprintf(f, "\n  in_hw");
+		else if (flags & TCA_CLS_FLAGS_NOT_IN_HW)
+			fprintf(f, "\n  not_in_hw");
 	}
 
 	if (tb[TCA_MATCHALL_ACT])
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 92c1fcd..ff700e9 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1264,6 +1264,11 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 			fprintf(f, "skip_hw ");
 		if (flags & TCA_CLS_FLAGS_SKIP_SW)
 			fprintf(f, "skip_sw ");
+
+		if (flags & TCA_CLS_FLAGS_IN_HW)
+			fprintf(f, "in_hw ");
+		else if (flags & TCA_CLS_FLAGS_NOT_IN_HW)
+			fprintf(f, "not_in_hw ");
 	}
 
 	if (tb[TCA_U32_PCNT]) {
-- 
2.3.7
