From: Joe Perches <joe@perches.com>
Subject: [PATCH 18/24] sctp: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:37 -0700
Message-ID: <21b4d996c8861373ac77d427914ec7882fe0c83e.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sctp/protocol.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 91784f4..0801444 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1326,7 +1326,6 @@ SCTP_STATIC __init int sctp_init(void)
 			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
 	} while (!sctp_assoc_hashtable && --order > 0);
 	if (!sctp_assoc_hashtable) {
-		pr_err("Failed association hash alloc\n");
 		status = -ENOMEM;
 		goto err_ahash_alloc;
 	}
@@ -1340,7 +1339,6 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_ep_hashtable = (struct sctp_hashbucket *)
 		kmalloc(64 * sizeof(struct sctp_hashbucket), GFP_KERNEL);
 	if (!sctp_ep_hashtable) {
-		pr_err("Failed endpoint_hash alloc\n");
 		status = -ENOMEM;
 		goto err_ehash_alloc;
 	}
@@ -1359,7 +1357,6 @@ SCTP_STATIC __init int sctp_init(void)
 			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
 	} while (!sctp_port_hashtable && --order > 0);
 	if (!sctp_port_hashtable) {
-		pr_err("Failed bind hash alloc\n");
 		status = -ENOMEM;
 		goto err_bhash_alloc;
 	}
-- 
1.7.6.405.gc1be0
