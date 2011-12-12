From: chetan loke <loke.chetan@gmail.com>
Subject: Re: vmxnet3 driver broken since 3.0?
Date: Mon, 12 Dec 2011 12:09:33 -0500
Message-ID: <CAAsGZS7QL1vQwoq7k2RX_LWeqgE4x5+00NSrRYbCu8vQoGh1Hg@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B9150914BA@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: pv-drivers@vmware.com, sandr8@gmail.com, zbiggy@o2.pl,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45314 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab1LLRJe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 12:09:34 -0500
Received: by dajs34 with SMTP id s34so1890524daj.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 09:09:34 -0800 (PST)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B9150914BA@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Alessandro Salvatori
> Sent: December 12, 2011 2:55 AM
> To: Zbigniew Luszpinski
> Cc: netdev@vger.kernel.org
> Subject: Re: vmxnet3 driver broken since 3.0?
>
> I guess this is the change that was introduced in 3.0 and that breaks=
 vmxnet3:
>
> commit 55513fb4281464e97aa1ff2b9c906ca5aed917c5
> Author: Tom Herbert <therbert@google.com>
> Date: =C2=A0 Mon Oct 18 17:55:58 2010 +0000
>
> =C2=A0 =C2=A0net: fail alloc_netdev_mq if queue count < 1
>
> =C2=A0 =C2=A0In alloc_netdev_mq fail if requested queue_count < 1.
>
> =C2=A0 =C2=A0Signed-off-by: Tom Herbert <therbert@google.com>
> =C2=A0 =C2=A0Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 04972a4..f44d29a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int
> sizeof_priv, const char *name,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(strlen(name) >=3D sizeof(dev->name)=
);
>
> + =C2=A0 =C2=A0 =C2=A0 if (queue_count < 1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("alloc_netd=
ev: Unable to allocate device "
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0"with zero queues.\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_size =3D sizeof(struct net_device);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sizeof_priv) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* ensure 32-b=
yte alignment of private area */
>
> thanks!
> -Alessandro-


CC'd VMware.
