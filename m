From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, verifier: annotate verbose printer with __printf
Date: Tue,  3 Nov 2015 11:39:20 +0100
Message-ID: <148eb693cd6fe017da1c5a564d972c06cb24166b.1446546825.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58433 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbKCKjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 05:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The verbose() printer dumps the verifier state to user space, so let gcc
take care to check calls to verbose() for (future) errors. make with W=1
correctly suggests: function might be possible candidate for 'gnu_printf'
format attribute [-Wsuggest-attribute=format].

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index fdc88c5..c607305 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -214,7 +214,7 @@ static DEFINE_MUTEX(bpf_verifier_lock);
  * verbose() is used to dump the verification trace to the log, so the user
  * can figure out what's wrong with the program
  */
-static void verbose(const char *fmt, ...)
+static __printf(1, 2) void verbose(const char *fmt, ...)
 {
 	va_list args;
 
-- 
1.9.3
