From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master] {f,m}_bpf: dump tag over insns
Date: Thu, 23 Feb 2017 13:07:14 +0100
Message-ID: <ca13968c577a5b3b9cbdb0aeaf637b7b7c168e69.1487850643.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40687 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdBWMHW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 07:07:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already export TCA_BPF_TAG resp. TCA_ACT_BPF_TAG from kernel commit
f1f7714ea51c ("bpf: rework prog_digest into prog_tag"), thus also dump
it when filter/actions are shown.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/f_bpf.c | 9 +++++++++
 tc/m_bpf.c | 9 +++++++++
 2 files changed, 18 insertions(+)

diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index c4764d8..df8a259 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -216,6 +216,15 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
 
+	if (tb[TCA_BPF_TAG]) {
+		SPRINT_BUF(b);
+
+		fprintf(f, "tag %s ",
+			hexstring_n2a(RTA_DATA(tb[TCA_BPF_TAG]),
+				      RTA_PAYLOAD(tb[TCA_BPF_TAG]),
+				      b, sizeof(b)));
+	}
+
 	if (tb[TCA_BPF_POLICE]) {
 		fprintf(f, "\n");
 		tc_print_police(f, tb[TCA_BPF_POLICE]);
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index f043ae4..1ddc334 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -177,6 +177,15 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " ");
 	}
 
+	if (tb[TCA_ACT_BPF_TAG]) {
+		SPRINT_BUF(b);
+
+		fprintf(f, "tag %s ",
+			hexstring_n2a(RTA_DATA(tb[TCA_ACT_BPF_TAG]),
+				      RTA_PAYLOAD(tb[TCA_ACT_BPF_TAG]),
+				      b, sizeof(b)));
+	}
+
 	fprintf(f, "default-action %s\n", action_n2a(parm->action));
 	fprintf(f, "\tindex %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
-- 
1.9.3
