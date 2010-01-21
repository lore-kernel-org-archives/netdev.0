From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Thu, 21 Jan 2010 15:54:13 +0800
Message-ID: <412e6f7f1001202354g1022bb64rae267a1b19713b8a@mail.gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:39083 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab0AUHyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 02:54:15 -0500
Received: by fxm20 with SMTP id 20so1001815fxm.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 23:54:13 -0800 (PST)
In-Reply-To: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 5:56 AM, Tom Herbert <therbert@google.com> wrot=
e:
> +/*
> + * get_rps_cpu is called from netif_receive_skb and returns the targ=
et
> + * CPU from the RPS map of the receiving NAPI instance for a given s=
kb.
> + */
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
> + =C2=A0 =C2=A0 =C2=A0 u32 addr1, addr2, ports;
> + =C2=A0 =C2=A0 =C2=A0 struct ipv6hdr *ip6;
> + =C2=A0 =C2=A0 =C2=A0 struct iphdr *ip;
> + =C2=A0 =C2=A0 =C2=A0 u32 ihl;
> + =C2=A0 =C2=A0 =C2=A0 u8 ip_proto;
> + =C2=A0 =C2=A0 =C2=A0 int cpu =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 struct dev_rps_maps *drmap;
> + =C2=A0 =C2=A0 =C2=A0 struct rps_map *map =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 u16 index;
> +
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> +
> + =C2=A0 =C2=A0 =C2=A0 drmap =3D rcu_dereference(dev->dev_rps_maps);
> + =C2=A0 =C2=A0 =C2=A0 if (!drmap)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto done;
> +
> + =C2=A0 =C2=A0 =C2=A0 index =3D skb_get_rx_queue(skb);
> + =C2=A0 =C2=A0 =C2=A0 if (index >=3D drmap->num_maps)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 index =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 map =3D (struct rps_map *)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((void *)drmap->maps + (rps_map_=
size * index));
> + =C2=A0 =C2=A0 =C2=A0 if (!map->len)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto done;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (skb->rxhash)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto got_hash; /* =
Skip hash computation on packet header */
> +

Sometimes, rxhash will be 0 generated. In order to check whether
rxhash is generated or not, a new bit field in sk_buff is needed. When
rxhash is generated and saved in sk_buff, the bit is set.

And, I think rxhash should be reserved when calling skb_copy and skb_cl=
one.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
