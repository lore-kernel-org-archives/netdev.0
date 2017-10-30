From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] net: filter: remove unused variable and fix warning
Date: Mon, 30 Oct 2017 13:46:47 -0700
Message-ID: <20171030204647.854-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Lawrence Brakmo <brakmo@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:50362 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752036AbdJ3UrG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:47:06 -0400
Received: by mail-pf0-f193.google.com with SMTP id b6so11958364pfh.7
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:47:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_getsockopt bpf call sets the ret variable to zero and
never changes it.  What's worse in case CONFIG_INET is
not selected the variable is completely unused generating
a warning.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 net/core/filter.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 721c30889033..a0112168d6f9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3288,7 +3288,6 @@ BPF_CALL_5(bpf_getsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 	   int, level, int, optname, char *, optval, int, optlen)
 {
 	struct sock *sk = bpf_sock->sk;
-	int ret = 0;
 
 	if (!sk_fullsock(sk))
 		goto err_clear;
@@ -3308,7 +3307,7 @@ BPF_CALL_5(bpf_getsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 	} else {
 		goto err_clear;
 	}
-	return ret;
+	return 0;
 #endif
 err_clear:
 	memset(optval, 0, optlen);
-- 
2.14.1
