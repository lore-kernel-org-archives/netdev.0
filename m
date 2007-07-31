From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH 20] net/decnet/dn_route.c: kmalloc + memset conversion to kzalloc
Date: Tue, 31 Jul 2007 19:33:33 +0200
Message-ID: <200707311933.33745.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, patrick@tykepenguin.com
To: linux-kernel@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <200707311845.48807.m.kozlowski@tuxland.pl>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 net/decnet/dn_route.c | 45013 -> 44991 (-22 bytes)
 net/decnet/dn_route.o | 199388 -> 199580 (+192 bytes)

 net/decnet/dn_route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.23-rc1-mm1-a/net/decnet/dn_route.c	2007-07-26 13:07:44.000000000 +0200
+++ linux-2.6.23-rc1-mm1-b/net/decnet/dn_route.c	2007-07-31 15:15:11.000000000 +0200
@@ -1737,8 +1737,9 @@ static int dn_rt_cache_seq_open(struct i
 {
 	struct seq_file *seq;
 	int rc = -ENOMEM;
-	struct dn_rt_cache_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
-
+	struct dn_rt_cache_iter_state *s;
+
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
 		goto out;
 	rc = seq_open(file, &dn_rt_cache_seq_ops);
@@ -1746,7 +1747,6 @@ static int dn_rt_cache_seq_open(struct i
 		goto out_kfree;
 	seq		= file->private_data;
 	seq->private	= s;
-	memset(s, 0, sizeof(*s));
 out:
 	return rc;
 out_kfree:
