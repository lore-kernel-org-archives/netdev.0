From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net PATCH] ipv4: Do not allow MAIN to be alias for new LOCAL w/
 custom rules
Date: Mon, 02 Jan 2017 13:32:54 -0800
Message-ID: <20170102213214.13707.86757.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jjk@jjacky.com, davem@davemloft.net,
        dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35511 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755786AbdABVc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 16:32:56 -0500
Received: by mail-pg0-f65.google.com with SMTP id i5so31424194pgh.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 13:32:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In the case of custom rules being present we need to handle the case of the
LOCAL table being intialized after the new rule has been added.  To address
that I am adding a new check so that we can make certain we don't use an
alias of MAIN for LOCAL when allocating a new table.

Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
Reported-by: Oliver Brunel <jjk@jjacky.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_frontend.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3ff8938893ec..eae0332b0e8c 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -85,7 +85,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	if (tb)
 		return tb;
 
-	if (id == RT_TABLE_LOCAL)
+	if (id == RT_TABLE_LOCAL && !net->ipv4.fib_has_custom_rules)
 		alias = fib_new_table(net, RT_TABLE_MAIN);
 
 	tb = fib_trie_table(id, alias);
