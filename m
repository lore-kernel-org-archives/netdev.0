From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] [NEIGH]: Provide number of probes to userspace
Date: Fri, 4 Mar 2005 03:31:21 +0100
Message-ID: <20050304023121.GC31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Provides number of probes done so far to userspace, quite useful for debugging.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11.orig/include/linux/rtnetlink.h	2005-03-04 00:45:01.000000000 +0100
+++ linux-2.6.11/include/linux/rtnetlink.h	2005-03-04 02:26:25.000000000 +0100
@@ -446,6 +446,7 @@
 	NDA_DST,
 	NDA_LLADDR,
 	NDA_CACHEINFO,
+	NDA_PROBES,
 	__NDA_MAX
 };
 
--- linux-2.6.11.orig/net/core/neighbour.c	2005-03-04 02:26:20.000000000 +0100
+++ linux-2.6.11/net/core/neighbour.c	2005-03-04 02:26:25.000000000 +0100
@@ -1554,6 +1554,7 @@
 	unsigned char *b = skb->tail;
 	struct nda_cacheinfo ci;
 	int locked = 0;
+	u32 probes;
 	struct nlmsghdr *nlh = NLMSG_PUT(skb, pid, seq, event,
 					 sizeof(struct ndmsg));
 	struct ndmsg *ndm = NLMSG_DATA(nlh);
@@ -1573,9 +1574,11 @@
 	ci.ndm_confirmed = now - n->confirmed;
 	ci.ndm_updated	 = now - n->updated;
 	ci.ndm_refcnt	 = atomic_read(&n->refcnt) - 1;
+	probes = atomic_read(&n->probes);
 	read_unlock_bh(&n->lock);
 	locked		 = 0;
 	RTA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
+	RTA_PUT(skb, NDA_PROBES, sizeof(probes), &probes);
 	nlh->nlmsg_len	 = skb->tail - b;
 	return skb->len;
 
