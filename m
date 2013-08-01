From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] vlan: cleanup the usage of *vlan in vlan_dev_hard_header
Date: Thu, 01 Aug 2013 14:10:23 +0800
Message-ID: <51F9FBCF.9060405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:53138 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab3HAGLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 02:11:39 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so1671173pbc.30
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 23:11:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use vlan directly after we get the pointer at the beginning
     *vlan = vlan_dev_priv(dev)
and do not use vlan_dev_priv(dev) to access its fields afterwards.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
  net/8021q/vlan_dev.c |    6 +++---
  1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1cd3d2a..9ab8a7e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -107,10 +107,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
  	u16 vlan_tci = 0;
  	int rc;

-	if (!(vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan->flags & VLAN_FLAG_REORDER_HDR)) {
  		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);

-		vlan_tci = vlan_dev_priv(dev)->vlan_id;
+		vlan_tci = vlan->vlan_id;
  		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
  		vhdr->h_vlan_TCI = htons(vlan_tci);

@@ -133,7 +133,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
  		saddr = dev->dev_addr;

  	/* Now make the underlying real hard header */
-	dev = vlan_dev_priv(dev)->real_dev;
+	dev = vlan->real_dev;
  	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
  	if (rc > 0)
  		rc += vhdrlen;
-- 
1.7.10.4
