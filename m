From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: filter: Use kcalloc/kmalloc_array to allocate arrays
Date: Tue, 24 Jun 2014 15:33:22 +0200
Message-ID: <1403616802-25743-3-git-send-email-tklauser@distanz.ch>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57139 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbaFXNeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 09:34:04 -0400
In-Reply-To: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kcalloc/kmalloc_array to make it clear we're allocating arrays. No
integer overflow can actually happen here, since len/flen is guaranteed
to be less than BPF_MAXINSNS (4096). However, this changed makes sure
we're not going to get one if BPF_MAXINSNS were ever increased.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/filter.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ed8d929..e44c1c4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -844,7 +844,7 @@ int sk_convert_filter(struct sock_filter *prog, int len,
 		return -EINVAL;
 
 	if (new_prog) {
-		addrs = kzalloc(len * sizeof(*addrs), GFP_KERNEL);
+		addrs = kcalloc(len, sizeof(*addrs), GFP_KERNEL);
 		if (!addrs)
 			return -ENOMEM;
 	}
@@ -1101,7 +1101,7 @@ static int check_load_and_stores(struct sock_filter *filter, int flen)
 
 	BUILD_BUG_ON(BPF_MEMWORDS > 16);
 
-	masks = kmalloc(flen * sizeof(*masks), GFP_KERNEL);
+	masks = kmalloc_array(flen, sizeof(*masks), GFP_KERNEL);
 	if (!masks)
 		return -ENOMEM;
 
-- 
1.7.9.5
