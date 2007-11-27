From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH] [NET]: Fix TX bug VLAN in VLAN
Date: Tue, 27 Nov 2007 16:02:19 +0900
Message-ID: <002801c830c3$783319f0$9c94fea9@jason>
References: <003f01c82dca$305acd40$9c94fea9@jason> <20071126112631.GA26599@gondor.apana.org.au> <b25c3fa70711262132r3f88db02mcede6d14b82d5fc0@mail.gmail.com> <20071127063859.GB2942@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <tristan_schmelcher@alumni.uwaterloo.ca>,
	<acme@ghostprotocols.net>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:2092 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbXK0HCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 02:02:38 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1115824wah
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 23:02:38 -0800 (PST)
In-Reply-To: <20071127063859.GB2942@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/27, Herbert Xu <herbert@gondor.apana.org.au>:
> On Tue, Nov 27, 2007 at 02:32:49PM +0900, Joonwoo Park wrote:
> >
> > Thanks Herbert.
> > Well.. I think patch would work propely for AF_PACKET also.
> > (I did not insert BUG() macro in my patch)
> > How do you think?
> 
> Are you sure? I thought you need to check both in the xmit function.
> That is,
> 
>        if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
>            VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR) {
> 
> Otherwise you'll miss AF_PACKET packets when REORDER is off.

Thanks Herbert!
I agree with you.

Thanks.
Joonwoo

[NET]: Fix TX bug VLAN in VLAN
Fix misbehavior of vlan_dev_hard_start_xmit() for recursive encapsulations.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

---
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7a36878..4f99bb8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -462,7 +462,8 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
+		VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 
---

