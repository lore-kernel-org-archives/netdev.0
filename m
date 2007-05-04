From: Patrick McHardy <kaber@trash.net>
Subject: Re: git-net locking bustage
Date: Fri, 04 May 2007 21:02:56 +0200
Message-ID: <463B8360.10805@trash.net>
References: <20070504115316.998c7fd3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090001000700080702000304"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61965 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434AbXEDTDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:03:25 -0400
In-Reply-To: <20070504115316.998c7fd3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090001000700080702000304
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> kernel BUG at net/netlink/af_netlink.c:144!


The BUG_ON(mutex_is_locked(nlk_sk(sk)->cb_mutex)) is bogus,
this patch removes it.


--------------090001000700080702000304
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: Remove bogus BUG_ON

Remove bogus BUG_ON(mutex_is_locked(nlk_sk(sk)->cb_mutex)), when the
netlink_kernel_create caller specifies an external mutex it might
validly be locked.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c83f581b321efb7e7119c9f906ba8ecb6c43541d
tree 4430e76db65599f1c02d1eaeec0b0606ea167175
parent 572b08f6ad7d473edd282fd40ceadbb4dce522a2
author Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 21:02:24 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 21:02:24 +0200

 net/netlink/af_netlink.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ac1cead..507828d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -142,7 +142,6 @@ static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
-	BUG_ON(mutex_is_locked(nlk_sk(sk)->cb_mutex));
 	if (nlk->cb) {
 		if (nlk->cb->done)
 			nlk->cb->done(nlk->cb);

--------------090001000700080702000304--
