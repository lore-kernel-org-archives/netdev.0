From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Fri, 3 Jun 2011 07:18:10 +0800
Message-ID: <BANLkTikKZy09vsMZgoQy-cKS_XX53gqjkw@mail.gmail.com>
References: <m1aaectyed.fsf@fess.ebiederm.org> <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org> <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org> <BANLkTimjfHKh3dpPEzznKiK=Md4v0iTD9A@mail.gmail.com>
 <m1ipsob6f8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51980 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab1FBXSb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 19:18:31 -0400
Received: by bwz15 with SMTP id 15so1342125bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 16:18:30 -0700 (PDT)
In-Reply-To: <m1ipsob6f8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 2, 2011 at 11:26 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Changli Gao <xiaosuo@gmail.com> writes:
>
>> On Thu, Jun 2, 2011 at 9:03 PM, Eric W. Biederman <ebiederm@xmission=
=2Ecom> wrote:
>>>
>>> -static struct sk_buff *vlan_check_reorder_header(struct sk_buff *s=
kb)
>>> +static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
>>> =A0{
>>> - =A0 =A0 =A0 if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDE=
R_HDR) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) <=
 0)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's=
 VLAN code... */
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - E=
TH_HLEN,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->=
data - VLAN_ETH_HLEN, 12);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D =
VLAN_HLEN;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
>>> + =A0 =A0 =A0 if (skb) {
>>
>> I think an else branch maybe more readable here.
>
> Probably most readable would be simply returning NULL immediately on
> error. =A0In this patch I just removed the if statement, and I would =
like
> to avoid mixing different bug fixes in the same patch if possible.
>

OK. It is minor.

>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's VLAN code... */
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - ETH_HLEN,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data - VLAN_ETH_=
HLEN, 12);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D VLAN_HLEN;
>>
>> skb->mac_len should be adjusted too.
>
> Given how vlan_untag is called at the moment it does appear
> that the skb->mac_len =3D skb->network_header - skb->mac_header
> in __netif_receive_skb that used to handle this for is no longer
> doing this for us.
>
> My feel is that either we need to do all of the header resets and the
> vlan_untagging together. =A0So we either need this all together befor=
e or
> after the another_round label:
>
> So the proper fix is probably something like this.
>

OK, it is right. Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
