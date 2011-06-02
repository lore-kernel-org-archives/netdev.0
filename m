From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Thu, 02 Jun 2011 08:26:51 -0700
Message-ID: <m1ipsob6f8.fsf@fess.ebiederm.org>
References: <m1aaectyed.fsf@fess.ebiederm.org>
	<20110524.022406.2228892895515155850.davem@davemloft.net>
	<m1oc2spmyt.fsf@fess.ebiederm.org>
	<20110601.205940.1179055860757569997.davem@davemloft.net>
	<m11uzcidvq.fsf_-_@fess.ebiederm.org>
	<BANLkTimjfHKh3dpPEzznKiK=Md4v0iTD9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44222 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1FBP1B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 11:27:01 -0400
In-Reply-To: <BANLkTimjfHKh3dpPEzznKiK=Md4v0iTD9A@mail.gmail.com> (Changli
	Gao's message of "Thu, 2 Jun 2011 22:54:50 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:

> On Thu, Jun 2, 2011 at 9:03 PM, Eric W. Biederman <ebiederm@xmission.=
com> wrote:
>>
>> -static struct sk_buff *vlan_check_reorder_header(struct sk_buff *sk=
b)
>> +static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 if (vlan_dev_info(skb->dev)->flags & VLAN_FLA=
G_REORDER_HDR) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (skb_cow(skb, =
skb_headroom(skb)) < 0)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 skb =3D NULL;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (skb) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* Lifted from Gleb's VLAN code... */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 memmove(skb->data - ETH_HLEN,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->data - VLAN_ETH_HLEN, 12);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 skb->mac_header +=3D VLAN_HLEN;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 if (skb_cow(skb, skb_headroom(skb)) < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb =3D NULL;
>> + =C2=A0 =C2=A0 =C2=A0 if (skb) {
>
> I think an else branch maybe more readable here.

Probably most readable would be simply returning NULL immediately on
error.  In this patch I just removed the if statement, and I would like
to avoid mixing different bug fixes in the same patch if possible.

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Lifted from Gl=
eb's VLAN code... */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memmove(skb->data=
 - ETH_HLEN,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 skb->data - VLAN_ETH_HLEN, 12);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->mac_header +=
=3D VLAN_HLEN;
>
> skb->mac_len should be adjusted too.

Given how vlan_untag is called at the moment it does appear
that the skb->mac_len =3D skb->network_header - skb->mac_header
in __netif_receive_skb that used to handle this for is no longer
doing this for us.

My feel is that either we need to do all of the header resets and the
vlan_untagging together.  So we either need this all together before or
after the another_round label:

So the proper fix is probably something like this.

diff --git a/net/core/dev.c b/net/core/dev.c
index bcb05cb..8fe50d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3102,9 +3102,6 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 		skb->skb_iif =3D skb->dev->ifindex;
 	orig_dev =3D skb->dev;
=20
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	skb->mac_len =3D skb->network_header - skb->mac_header;
=20
 	pt_prev =3D NULL;
=20
@@ -3119,6 +3116,9 @@ another_round:
 		if (unlikely(!skb))
 			goto out;
 	}
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->mac_len =3D skb->network_header - skb->mac_header;
=20
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
