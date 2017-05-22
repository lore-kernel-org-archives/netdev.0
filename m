From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: make struct inet_frags::qsize unsigned
Date: Tue, 23 May 2017 00:20:26 +0300
Message-ID: <20170522212026.GA28769@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36311 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936015AbdEVVUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:20:31 -0400
Received: by mail-lf0-f66.google.com with SMTP id h4so6455160lfj.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:20:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field is sizeof of corresponding kmem_cache so it can't be negative.

Prepare for 32-bit kmem_cache_create().

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/inet_frag.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -92,7 +92,7 @@ struct inet_frags {
 	 */
 	u32			rnd;
 	seqlock_t		rnd_seqlock;
-	int			qsize;
+	unsigned int		qsize;
 
 	unsigned int		(*hashfn)(const struct inet_frag_queue *);
 	bool			(*match)(const struct inet_frag_queue *q,
