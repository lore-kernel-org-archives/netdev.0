From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Thu, 2 Jun 2011 22:54:50 +0800
Message-ID: <BANLkTimjfHKh3dpPEzznKiK=Md4v0iTD9A@mail.gmail.com>
References: <m1aaectyed.fsf@fess.ebiederm.org> <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org> <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org>
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
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59887 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab1FBOzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 10:55:12 -0400
Received: by bwz15 with SMTP id 15so992067bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 07:55:10 -0700 (PDT)
In-Reply-To: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 2, 2011 at 9:03 PM, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
>
> -static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb=
)
> +static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
> =A0{
> - =A0 =A0 =A0 if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_=
HDR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's V=
LAN code... */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - ETH=
_HLEN,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->da=
ta - VLAN_ETH_HLEN, 12);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D VL=
AN_HLEN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
> + =A0 =A0 =A0 if (skb) {

I think an else branch maybe more readable here.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's VLAN code... */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - ETH_HLEN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data - VLAN_ETH_HL=
EN, 12);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D VLAN_HLEN;

skb->mac_len should be adjusted too.

> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return skb;
> =A0}




--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
