From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 13/18] net: ppp: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:09 +0800
Message-ID: <1381837514-50660-14-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:5438 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467Ab3JOL6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 07:58:14 -0400
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_ratelimited_function() is called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/ppp/ppp_generic.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 72ff14b..53900cd 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1125,8 +1125,8 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 		ppp->xcomp->comp_extra + PPP_HDRLEN;
 	new_skb = alloc_skb(new_skb_size, GFP_ATOMIC);
 	if (!new_skb) {
-		if (net_ratelimit())
-			netdev_err(ppp->dev, "PPP: no memory (comp pkt)\n");
+		net_ratelimited_function(netdev_err, ppp->dev,
+			"PPP: no memory (comp pkt)\n");
 		return NULL;
 	}
 	if (ppp->dev->hard_header_len > PPP_HDRLEN)
@@ -1155,8 +1155,8 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 		 * the compress_proto because MPPE and MPPC share
 		 * the same number.
 		 */
-		if (net_ratelimit())
-			netdev_err(ppp->dev, "ppp: compressor dropped pkt\n");
+		net_ratelimited_function(netdev_err, ppp->dev,
+			"ppp: compressor dropped pkt\n");
 		kfree_skb(skb);
 		consume_skb(new_skb);
 		new_skb = NULL;
@@ -1251,8 +1251,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state &&
 	    proto != PPP_LCP && proto != PPP_CCP) {
 		if (!(ppp->flags & SC_CCP_UP) && (ppp->flags & SC_MUST_COMP)) {
-			if (net_ratelimit())
-				netdev_err(ppp->dev,
+			net_ratelimited_function(netdev_err, ppp->dev,
 					   "ppp: compression required but "
 					   "down - pkt dropped.\n");
 			goto drop;
-- 
1.8.2.1
