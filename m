From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Sat, 14 Nov 2009 20:14:28 +0800
Message-ID: <412e6f7f0911140414x4918d8d2teb60ee585ebdfce9@mail.gmail.com>
References: <412e6f7f0911131650j6d13f95bt20aa607f9f44c3af@mail.gmail.com>
	 <4AFE621C.1020004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:34948 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbZKNMOW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 07:14:22 -0500
Received: by pzk1 with SMTP id 1so1851459pzk.33
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 04:14:28 -0800 (PST)
In-Reply-To: <4AFE621C.1020004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2009 at 3:54 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
>
> Please always use scripts/checkpatch.pl before sending patches
>
> } else if((select_queue =3D dev->netdev_ops->ndo_select_queue)) {
>
> A space is required after the "if"
>

Thanks.

> It seems to me this patch is not matching its ChangeLog :
>
> You moved the :
>
> if (sk && sk->sk_dst_cache)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sk_tx_queue_set(sk, queue_index);

Maybe I did more in my patch, but I think these little changes doesn't
need separate patches.

>
> Why not using much readable patch like :
>
>
> [PATCH] check the return value of ndo_select_queue()
>
> check the return value of ndo_select_queue()
>
> Check the return value of ndo_select_queue(). If the value isn't smal=
ler
> than the real_num_tx_queues, print a warning message, and reset it to=
 zero.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ----
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ad8e320..bbc9a41 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1845,6 +1845,20 @@ u16 skb_tx_hash(const struct net_device *dev, =
const struct sk_buff *skb)
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(skb_tx_hash);
>
> +static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_=
index)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(queue_index >=3D dev->real_num_tx=
_queues)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit(=
)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 WARN(1, "%s selects TX queue %d, but "
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0"real number of TX queues is %d\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->name, queue_index,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->real_num_tx_queues);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return queue_index;
> +}
> +
> =C2=A0static struct netdev_queue *dev_pick_tx(struct net_device *dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s=
truct sk_buff *skb)
> =C2=A0{
> @@ -1858,6 +1872,7 @@ static struct netdev_queue *dev_pick_tx(struct =
net_device *dev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ops->ndo_s=
elect_queue) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0queue_index =3D ops->ndo_select_queue(dev, skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 queue_index =3D dev_cap_txqueue(dev, queue_index);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0queue_index =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (dev->real_num_tx_queues > 1)
>
>
>

It seems better than mime.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
