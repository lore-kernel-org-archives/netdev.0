From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] tc: act_bpf: fix memory leak
Date: Tue, 14 Jul 2015 12:15:19 -0700
Message-ID: <1436901319-705-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35467 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbbGNTP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 15:15:27 -0400
Received: by pactm7 with SMTP id tm7so10219869pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 12:15:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prog->bpf_ops is populated when act_bpf is used with classic BPF and
prog->bpf_name is optionally used with extended BPF.
Fix memory leak when act_bpf is released.

Fixes: d23b8ad8ab23 ("tc: add BPF based action")
Fixes: a8cb5f556b56 ("act_bpf: add initial eBPF support for actions")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/act_bpf.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1d56903fd4c7..1df78289e248 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -339,6 +339,9 @@ static void tcf_bpf_cleanup(struct tc_action *act, int bind)
 		bpf_prog_put(prog->filter);
 	else
 		bpf_prog_destroy(prog->filter);
+
+	kfree(prog->bpf_ops);
+	kfree(prog->bpf_name);
 }
 
 static struct tc_action_ops act_bpf_ops __read_mostly = {
-- 
1.7.9.5
