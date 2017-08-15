From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] net/9p: Delete an error message for a failed memory
 allocation in five functions
Date: Tue, 15 Aug 2017 13:58:36 +0200
Message-ID: <e703fb59-bdc3-fd0d-3cba-3ec970c9328a@users.sourceforge.net>
References: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Ron Minnich <rminnich@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Aug 2017 08:25:41 +0200

Omit an extra message for a memory allocation failure in these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/9p/client.c       | 7 ++-----
 net/9p/trans_fd.c     | 6 ++----
 net/9p/trans_rdma.c   | 6 ++----
 net/9p/trans_virtio.c | 1 -
 4 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 4674235b0d9b..2273181e9ba9 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -160,11 +160,9 @@ static int parse_opts(char *opts, struct p9_client *clnt)
 		return 0;
 
 	tmp_options = kstrdup(opts, GFP_KERNEL);
-	if (!tmp_options) {
-		p9_debug(P9_DEBUG_ERROR,
-			 "failed to allocate copy of option string\n");
+	if (!tmp_options)
 		return -ENOMEM;
-	}
+
 	options = tmp_options;
 
 	while ((p = strsep(&options, ",")) != NULL) {
@@ -277,7 +275,6 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 					sizeof(struct p9_req_t), GFP_ATOMIC);
 
 			if (!c->reqs[row]) {
-				pr_err("Couldn't grow tag array\n");
 				spin_unlock_irqrestore(&c->lock, flags);
 				return ERR_PTR(-ENOMEM);
 			}
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index ddfa86648f95..3c272e5bc9ea 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -762,11 +762,9 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 		return 0;
 
 	tmp_options = kstrdup(params, GFP_KERNEL);
-	if (!tmp_options) {
-		p9_debug(P9_DEBUG_ERROR,
-			 "failed to allocate copy of option string\n");
+	if (!tmp_options)
 		return -ENOMEM;
-	}
+
 	options = tmp_options;
 
 	while ((p = strsep(&options, ",")) != NULL) {
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 6d8e3031978f..f98b6aae308b 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -205,11 +205,9 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 		return 0;
 
 	tmp_options = kstrdup(params, GFP_KERNEL);
-	if (!tmp_options) {
-		p9_debug(P9_DEBUG_ERROR,
-			 "failed to allocate copy of option string\n");
+	if (!tmp_options)
 		return -ENOMEM;
-	}
+
 	options = tmp_options;
 
 	while ((p = strsep(&options, ",")) != NULL) {
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index f24b25c25106..8a2cf9748398 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -552,7 +552,6 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 
 	chan = kmalloc(sizeof(struct virtio_chan), GFP_KERNEL);
 	if (!chan) {
-		pr_err("Failed to allocate virtio 9P channel\n");
 		err = -ENOMEM;
 		goto fail;
 	}
-- 
2.14.0
