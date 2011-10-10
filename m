From: Yinglin Sun <Yinglin.Sun@emc.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Mon, 10 Oct 2011 12:35:08 -0700
Message-ID: <CAN17JHVmrkTnz7mSjjG_vOUBY+n9rN+AgTxs-eJBcX6poteiiA@mail.gmail.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33052 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab1JJTfK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 15:35:10 -0400
Received: by bkbzt4 with SMTP id zt4so8829033bkb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 12:35:09 -0700 (PDT)
In-Reply-To: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 7, 2011 at 10:36 PM, Yinglin Sun <Yinglin.Sun@emc.com> wrot=
e:
> Add IPv6 support in L2L3 xmit policy.
> L3L4 doesn't support IPv6 either, and I'll try to fix that later.
>
> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
> ---
> =C2=A0drivers/net/bonding/bond_main.c | =C2=A0 =C2=A07 +++++++
> =C2=A01 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 6d79b78..d6fd282 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -41,8 +41,10 @@
> =C2=A0#include <linux/ptrace.h>
> =C2=A0#include <linux/ioport.h>
> =C2=A0#include <linux/in.h>
> +#include <linux/in6.h>
> =C2=A0#include <net/ip.h>
> =C2=A0#include <linux/ip.h>
> +#include <linux/ipv6.h>
> =C2=A0#include <linux/tcp.h>
> =C2=A0#include <linux/udp.h>
> =C2=A0#include <linux/slab.h>
> @@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct s=
k_buff *skb, int count)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *data =3D (struct ethhdr *)s=
kb->data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct iphdr *iph =3D ip_hdr(skb);
> + =C2=A0 =C2=A0 =C2=A0 struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP)) =
{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ((ntohl=
(iph->saddr ^ iph->daddr) & 0xffff) ^
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0(data->h_dest[5] ^ data->h_source[5])) % count;
> + =C2=A0 =C2=A0 =C2=A0 } else if (skb->protocol =3D=3D htons(ETH_P_IP=
V6)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ((ntohl(ipv=
6h->saddr.s6_addr32[3] ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ipv6h->daddr.s6_addr32[3]) & 0xffff)=
 ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (data->h_dest[5] ^ data->h_source[5])) % count;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return (data->h_dest[5] ^ data->h_source[5=
]) % count;
> --
> 1.7.4.1
>
>

Any comment on this patch? Thanks.

Yinglin
