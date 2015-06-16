From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: disallow bpf tc programs access current->pid,uid
Date: Mon, 15 Jun 2015 20:49:24 -0700
Message-ID: <1434426564-6176-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35760 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbFPDtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 23:49:32 -0400
Received: by pacyx8 with SMTP id yx8so4050108pac.2
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 20:49:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accessing current->pid/uid from cls_bpf may lead to misleading results and
should not be used when TC classifiers need accurate information about pid/uid.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 65ff107d3d29..be3098fb65e4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1461,12 +1461,6 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_l4_csum_replace_proto;
 	case BPF_FUNC_clone_redirect:
 		return &bpf_clone_redirect_proto;
-	case BPF_FUNC_get_current_pid_tgid:
-		return &bpf_get_current_pid_tgid_proto;
-	case BPF_FUNC_get_current_uid_gid:
-		return &bpf_get_current_uid_gid_proto;
-	case BPF_FUNC_get_current_comm:
-		return &bpf_get_current_comm_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.7.9.5
