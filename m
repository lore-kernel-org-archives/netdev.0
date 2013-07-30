From: Xishi Qiu <qiuxishi@huawei.com>
Subject: [PATCH] net: fix build warning in trans_rdma.c
Date: Tue, 30 Jul 2013 17:15:59 +0800
Message-ID: <51F7844F.60904@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <ericvh@gmail.com>, <rminnich@sandia.gov>, <lucho@ionkov.net>,
	<davem@davemloft.net>, <v9fs-developer@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building v3.11-rc3, I get the following warning:
=2E..
net/9p/trans_rdma.c:594: warning: =91rdma_cancelled=92 defined but not =
used
=2E..
As the function is not be used, so remove it.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 net/9p/trans_rdma.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 928f2bb..8f68df5 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -588,17 +588,6 @@ static int rdma_cancel(struct p9_client *client, s=
truct p9_req_t *req)
 	return 1;
 }
=20
-/* A request has been fully flushed without a reply.
- * That means we have posted one buffer in excess.
- */
-static int rdma_cancelled(struct p9_client *client, struct p9_req_t *r=
eq)
-{
-	struct p9_trans_rdma *rdma =3D client->trans;
-
-	atomic_inc(&rdma->excess_rc);
-	return 0;
-}
-
 /**
  * trans_create_rdma - Transport method for creating atransport instan=
ce
  * @client: client instance
--=20
1.7.1
