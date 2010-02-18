From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] AF_UNIX: update locking comment
Date: Thu, 18 Feb 2010 09:34:23 -0800
Message-ID: <20100218093423.52165efd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40978 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758612Ab0BRRfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 12:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lock used in unix_state_lock() is a spin_lock not reader-writer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/unix/af_unix.c	2010-02-18 09:29:38.948513483 -0800
+++ b/net/unix/af_unix.c	2010-02-18 09:32:18.584389536 -0800
@@ -144,7 +144,7 @@ static inline void unix_set_secdata(stru
 /*
  *  SMP locking strategy:
  *    hash table is protected with spinlock unix_table_lock
- *    each socket state is protected by separate rwlock.
+ *    each socket state is protected by separate spin lock.
  */
 
 static inline unsigned unix_hash_fold(__wsum n)
