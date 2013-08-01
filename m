From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: Re: [PATCH] vlan: cleanup the usage of *vlan in vlan_dev_hard_header
Date: Fri, 02 Aug 2013 07:58:46 +0800
Message-ID: <51FAF636.1090802@gmail.com>
References: <51F9FBCF.9060405@gmail.com> <20130801.131230.25199405118866430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:62878 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181Ab3HAX64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 19:58:56 -0400
Received: by mail-pd0-f169.google.com with SMTP id y11so13409pdj.14
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 16:58:55 -0700 (PDT)
In-Reply-To: <20130801.131230.25199405118866430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B408=E6=9C=8802=E6=97=A5 04:12, David Miller wrote:
> From: Wang Sheng-Hui <shhuiw@gmail.com>
> Date: Thu, 01 Aug 2013 14:10:23 +0800
>
>> We can use vlan directly after we get the pointer at the beginning
>>      *vlan =3D vlan_dev_priv(dev)
>> and do not use vlan_dev_priv(dev) to access its fields afterwards.
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>
> This patch was corrupted by your email client.
>

Sorry. Please recheck the patch below.
> Please read Documentation/email-clients.txt to learn how to
> fix this, send a test patch to yourself, and only when you
> can successfully apply the patch you receive in that test email
> should you repost your patch again here.
>
> Thanks.



We can use vlan directly after we get the pointer at the beginning
     *vlan =3D vlan_dev_priv(dev)
and do not use vlan_dev_priv(dev) to access its fields afterwords.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
  net/8021q/vlan_dev.c |    6 +++---
  1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1cd3d2a..9ab8a7e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -107,10 +107,10 @@ static int vlan_dev_hard_header(struct sk_buff *s=
kb, struct net_device *dev,
  	u16 vlan_tci =3D 0;
  	int rc;

-	if (!(vlan_dev_priv(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan->flags & VLAN_FLAG_REORDER_HDR)) {
  		vhdr =3D (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);

-		vlan_tci =3D vlan_dev_priv(dev)->vlan_id;
+		vlan_tci =3D vlan->vlan_id;
  		vlan_tci |=3D vlan_dev_get_egress_qos_mask(dev, skb);
  		vhdr->h_vlan_TCI =3D htons(vlan_tci);

@@ -133,7 +133,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb=
, struct net_device *dev,
  		saddr =3D dev->dev_addr;

  	/* Now make the underlying real hard header */
-	dev =3D vlan_dev_priv(dev)->real_dev;
+	dev =3D vlan->real_dev;
  	rc =3D dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
  	if (rc > 0)
  		rc +=3D vhdrlen;
--=20
1.7.10.4
