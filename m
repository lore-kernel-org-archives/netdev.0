From: akpm@linux-foundation.org
Subject: [patch 11/28] fix theoretical ccids_{read,write}_lock() race
Date: Fri, 10 Aug 2007 14:11:55 -0700
Message-ID: <200708102111.l7ALBteq009403@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, oleg@tv-sign.ru,
	acme@redhat.com, mingo@elte.hu
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55667 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755052AbXHJVMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oleg Nesterov <oleg@tv-sign.ru>

Make sure that spin_unlock_wait() is properly ordered wrt atomic_inc().

(akpm: can't we convert this code to use rwlocks?)

Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/ccid.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN net/dccp/ccid.c~fix-theoretical-ccids_readwrite_lock-race net/dccp/ccid.c
--- a/net/dccp/ccid.c~fix-theoretical-ccids_readwrite_lock-race
+++ a/net/dccp/ccid.c
@@ -40,6 +40,7 @@ static inline void ccids_write_unlock(vo
 static inline void ccids_read_lock(void)
 {
 	atomic_inc(&ccids_lockct);
+	smp_mb__after_atomic_inc();
 	spin_unlock_wait(&ccids_lock);
 }
 
_
