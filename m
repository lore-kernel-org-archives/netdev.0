From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] selftests/bpf: remove useless bpf_trace_printk
Date: Sat, 28 Oct 2017 17:17:13 -0700
Message-ID: <20171029001713.3552314-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35546 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751209AbdJ2ART (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 20:17:19 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v9T0HHEd030786
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 17:17:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2dvnjhsx30-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 17:17:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sockmap test is using two programs that use bpf_trace_printk()
which prints into trace_pipe, but nothing is reading it.
Remove it.

Fixes: 6f6d33f3b3d0 ("bpf: selftests add sockmap tests")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/sockmap_parse_prog.c   | 3 ---
 tools/testing/selftests/bpf/sockmap_verdict_prog.c | 2 --
 2 files changed, 5 deletions(-)

diff --git a/tools/testing/selftests/bpf/sockmap_parse_prog.c b/tools/testing/selftests/bpf/sockmap_parse_prog.c
index fae3b96c3aa4..a1dec2b6d9c5 100644
--- a/tools/testing/selftests/bpf/sockmap_parse_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_parse_prog.c
@@ -29,9 +29,6 @@ int bpf_prog1(struct __sk_buff *skb)
 	 * fields.
 	 */
 	d[7] = 1;
-
-	bpf_printk("parse: data[0] = (%u): local_port %i remote %i\n",
-		   d[0], lport, bpf_ntohl(rport));
 	return skb->len;
 }
 
diff --git a/tools/testing/selftests/bpf/sockmap_verdict_prog.c b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
index 2cd2d552938b..d7bea972cb21 100644
--- a/tools/testing/selftests/bpf/sockmap_verdict_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
@@ -58,8 +58,6 @@ int bpf_prog2(struct __sk_buff *skb)
 	d[6] = 0xe;
 	d[7] = 0xf;
 
-	bpf_printk("verdict: data[0] = redir(%u:%u)\n", map, sk);
-
 	if (!map)
 		return bpf_sk_redirect_map(skb, &sock_map_rx, sk, 0);
 	return bpf_sk_redirect_map(skb, &sock_map_tx, sk, 0);
-- 
2.9.5
