From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH 67] net/ipv4/route.c: mostly kmalloc + memset conversion to k[cz]alloc
Date: Tue, 31 Jul 2007 23:55:02 +0200
Message-ID: <200707312355.03321.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:1024 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761801AbXGaVzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 17:55:02 -0400
In-Reply-To: <200707311845.48807.m.kozlowski@tuxland.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 net/ipv4/route.c | 75650 -> 75628 (-22 bytes)
 net/ipv4/route.o | 256303 -> 256467 (+164 bytes)

 net/ipv4/route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.23-rc1-mm1-a/net/ipv4/route.c	2007-07-26 13:07:44.000000000 +0200
+++ linux-2.6.23-rc1-mm1-b/net/ipv4/route.c	2007-07-31 15:21:41.000000000 +0200
@@ -374,8 +374,9 @@ static int rt_cache_seq_open(struct inod
 {
 	struct seq_file *seq;
 	int rc = -ENOMEM;
-	struct rt_cache_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
-
+	struct rt_cache_iter_state *s;
+
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
 		goto out;
 	rc = seq_open(file, &rt_cache_seq_ops);
@@ -383,7 +384,6 @@ static int rt_cache_seq_open(struct inod
 		goto out_kfree;
 	seq          = file->private_data;
 	seq->private = s;
-	memset(s, 0, sizeof(*s));
 out:
 	return rc;
 out_kfree:
