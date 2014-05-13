From: David Rientjes <rientjes@google.com>
Subject: [patch] net, filter: make new test_bpf depend on networking
Date: Tue, 13 May 2014 12:57:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405131255380.3392@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:63398 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbaEMT56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 15:57:58 -0400
Received: by mail-pb0-f47.google.com with SMTP id un15so668554pbc.34
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 12:57:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_TEST_BPF depends on CONFIG_NET, otherwise the build fails:

ERROR: "sk_unattached_filter_destroy" [lib/test_bpf.ko] undefined!
ERROR: "kfree_skb" [lib/test_bpf.ko] undefined!
ERROR: "sk_unattached_filter_create" [lib/test_bpf.ko] undefined!
ERROR: "sk_run_filter_int_skb" [lib/test_bpf.ko] undefined!
ERROR: "__alloc_skb" [lib/test_bpf.ko] undefined!

Add the dependency.

Cc: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 lib/Kconfig.debug | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1639,6 +1639,7 @@ config TEST_USER_COPY
 config TEST_BPF
 	tristate "Test BPF filter functionality"
 	default n
+	depends on NET
 	depends on m
 	help
 	  This builds the "test_bpf" module that runs various test vectors
