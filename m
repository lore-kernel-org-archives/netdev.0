From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] include/net/raw.h: Convert raw_seq_private macro
 to inline
Date: Mon, 06 Sep 2010 22:01:17 -0700
Message-ID: <1283835677.23280.108.camel@Joe-Laptop>
References: <cover.1283650107.git.joe@perches.com>
	 <dd5d79c3aa9f2cffbca1a8d4a9163b0d6a9492a9.1283650107.git.joe@perches.com>
	 <20100906.183036.68150190.davem@davemloft.net>
	 <20100906.184749.214227378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1493 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab0IGFBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 01:01:19 -0400
In-Reply-To: <20100906.184749.214227378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-09-06 at 18:47 -0700, David Miller wrote:
> raw_seq_private() expands to something which dereferences the pointer,
> which you've now made void, which is illegal and breaks the build.
> Reverted.

Apologies, I had this in my tree which I didn't send
because it wasn't a private_data cast removal.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/raw.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/net/raw.h b/include/net/raw.h
index 43c5750..c621200 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -45,7 +45,10 @@ struct raw_iter_state {
 	struct raw_hashinfo *h;
 };
 
-#define raw_seq_private(seq) ((struct raw_iter_state *)(seq)->private)
+inline struct raw_iter_state *raw_seq_private(struct seq_file *seq)
+{
+	return seq->private;
+}
 void *raw_seq_start(struct seq_file *seq, loff_t *pos);
 void *raw_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 void raw_seq_stop(struct seq_file *seq, void *v);



