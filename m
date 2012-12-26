From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] netfilter: Don't leak 'exp' in ctnetlink_create_expect()
Date: Wed, 26 Dec 2012 22:49:40 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1212262246390.23814@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jay Schulist <jschlst@samba.org>,
	Harald Welte <laforge@gnumonks.org>
To: netfilter@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'if ((!help) && (!cda[CTA_EXPECT_TIMEOUT]))' then we should remember
to free 'exp' that was allocated by 'nf_ct_expect_alloc()' by jumping
to the 'err_out' label rather than the 'out' label in
ctnetlink_create_expect().
This patch should get rid of the leak.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

 note: compile tested only.

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e078cd..627b0e5 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2624,7 +2624,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	if (!help) {
 		if (!cda[CTA_EXPECT_TIMEOUT]) {
 			err = -EINVAL;
-			goto out;
+			goto err_out;
 		}
 		exp->timeout.expires =
 		  jiffies + ntohl(nla_get_be32(cda[CTA_EXPECT_TIMEOUT])) * HZ;
-- 
1.7.1


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

