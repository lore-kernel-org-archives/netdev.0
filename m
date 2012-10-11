From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] tcp: sysctl interface leaks 16 bytes of kernel memory
Date: Thu, 11 Oct 2012 17:24:14 +0100
Message-ID: <20121011162407.2590.40301.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:36058 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab2JKQWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 12:22:34 -0400
Received: from bob.linux.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q9BGsjE4020606
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 17:54:50 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

If the rc_dereference of tcp_fastopen_ctx ever fails then we copy 16 bytes
of kernel stack into the proc result.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/ipv4/sysctl_net_ipv4.c |    2 ++
 1 file changed, 2 insertions(+)


diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 9205e49..63d4ecc 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -248,6 +248,8 @@ int proc_tcp_fastopen_key(ctl_table *ctl, int write, void __user *buffer,
 	ctxt = rcu_dereference(tcp_fastopen_ctx);
 	if (ctxt)
 		memcpy(user_key, ctxt->key, TCP_FASTOPEN_KEY_LENGTH);
+	else
+		memset(user_key, 0, sizeof(user_key));
 	rcu_read_unlock();
 
 	snprintf(tbl.data, tbl.maxlen, "%08x-%08x-%08x-%08x",
