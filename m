From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] netfilter: use kfree_skb() not kfree()
Date: Sat, 30 Jun 2012 14:48:53 +0300
Message-ID: <20120630114853.GA22767@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Bart De Schuymer <bart.de.schuymer@pandora.be>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This was should be a kfree_skb() here to free the sk_buff pointer.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 1bd1732..dfbb019 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -156,7 +156,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	nlh = nlmsg_put(ub->skb, 0, ub->qlen, 0,
 			size - NLMSG_ALIGN(sizeof(*nlh)), 0);
 	if (!nlh) {
-		kfree(ub->skb);
+		kfree_skb(ub->skb);
 		ub->skb = NULL;
 		goto unlock;
 	}
