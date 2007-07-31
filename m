From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH 66] net/ipv4/raw.c: kmalloc + memset conversion to kzalloc
Date: Tue, 31 Jul 2007 23:54:00 +0200
Message-ID: <200707312354.00650.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <200707311845.48807.m.kozlowski@tuxland.pl>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 net/ipv4/raw.c | 21650 -> 21628 (-22 bytes)
 net/ipv4/raw.o | 179112 -> 179272 (+160 bytes)

 net/ipv4/raw.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.23-rc1-mm1-a/net/ipv4/raw.c	2007-07-26 13:07:44.000000000 +0200
+++ linux-2.6.23-rc1-mm1-b/net/ipv4/raw.c	2007-07-31 15:20:27.000000000 +0200
@@ -900,8 +900,9 @@ static int raw_seq_open(struct inode *in
 {
 	struct seq_file *seq;
 	int rc = -ENOMEM;
-	struct raw_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
-
+	struct raw_iter_state *s;
+
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
 		goto out;
 	rc = seq_open(file, &raw_seq_ops);
@@ -910,7 +911,6 @@ static int raw_seq_open(struct inode *in

 	seq = file->private_data;
 	seq->private = s;
-	memset(s, 0, sizeof(*s));
 out:
 	return rc;
 out_kfree:
