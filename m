From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] raw: Restore /proc/net/raw correct behavior
Date: Sun, 15 Jun 2008 12:22:38 +0200
Message-ID: <4854ED6E.2060602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:25291 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756951AbYFOKW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jun 2008 06:22:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just noticed "cat /proc/net/raw" was buggy, missing '\n' separators.

I believe this was introduced by commit 8cd850efa4948d57a2ed836911cfd1ab299e89c6 
([RAW]: Cleanup IPv4 raw_seq_show.)

This trivial patch restores correct behavior, and applies to current 
Linus tree (should also be applied to stable tree as well.)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index e7e091d..37a1ecd 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -934,7 +934,7 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	      srcp  = inet->num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		atomic_read(&sp->sk_wmem_alloc),
 		atomic_read(&sp->sk_rmem_alloc),


