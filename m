From: Joe Perches <joe@perches.com>
Subject: [PATCH 45/49] net/core/pktgen.c: Use vzalloc
Date: Thu,  4 Nov 2010 20:08:09 -0700
Message-ID: <01a5bd0185f5d41ce510c1e15358044f6c3b9349.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fbce4b0..ccca6cd 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3706,13 +3706,12 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		return -ENOMEM;
 
 	strcpy(pkt_dev->odevname, ifname);
-	pkt_dev->flows = vmalloc_node(MAX_CFLOWS * sizeof(struct flow_state),
+	pkt_dev->flows = vzalloc_node(MAX_CFLOWS * sizeof(struct flow_state),
 				      node);
 	if (pkt_dev->flows == NULL) {
 		kfree(pkt_dev);
 		return -ENOMEM;
 	}
-	memset(pkt_dev->flows, 0, MAX_CFLOWS * sizeof(struct flow_state));
 
 	pkt_dev->removal_mark = 0;
 	pkt_dev->min_pkt_size = ETH_ZLEN;
-- 
1.7.3.1.g432b3.dirty
