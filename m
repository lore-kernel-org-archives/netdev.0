From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 29 Apr 2010 13:50:08 +0300
Message-ID: <201004291350.08620.nuclearcat@nuclearcat.com>
References: <1271318553.16881.2161.camel@edumazet-laptop> <201004151211.28315.nuclearcat@nuclearcat.com> <1271327830.16881.2370.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:53339 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163Ab0D3QrB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:47:01 -0400
In-Reply-To: <1271327830.16881.2370.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 April 2010 13:37:10 Eric Dumazet wrote:
> Le jeudi 15 avril 2010 =C3=A0 12:11 +0300, Denys Fedorysychenko a =C3=
=A9crit :
> > Btw i have application using tun.
>=20
> Could you add following sanity test to catch the error ?
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fa8b476..b67274a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -988,6 +988,7 @@ static inline
>  struct netdev_queue *netdev_get_tx_queue(const struct net_device *de=
v,
>  					 unsigned int index)
>  {
> +	WARN_ON(index >=3D dev->num_tx_queues);
>  	return &dev->_tx[index];
>  }
>=20
Very sorry for being late, just i found way to stabilize kernel for me =
and to=20
solve my personal life issues. It took 2 weeks...
I will try this patch, but i'm sure i dont have multiqueue card there.

I had shaper on eth0.33 and eth0 so i disable all offloading except=20
checksumming there. Recently i found  that on some interfaces (where is=
 no=20
shaper) gso left on. And yes, probably some traffic was queued, then ro=
ute=20
changed, and maybe it went from gso off interface to gso on...=20
It can be just pure luck, that i dont have crashes anymore, but maybe t=
rick is=20
in gso...
