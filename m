From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Sat, 29 Mar 2008 09:18:03 +0100
Message-ID: <47EDFB3B.3060206@cosmosbay.com>
References: <47C92F49.4070100@cosmosbay.com>	<20080323.032949.194309002.davem@davemloft.net>	<47E6A5FD.6060407@cosmosbay.com> <20080328.183652.99818676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003av.neufgp.fr ([84.96.92.124]:39128 "EHLO
	neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750997AbYC2ISR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 04:18:17 -0400
In-Reply-To: <20080328.183652.99818676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 23 Mar 2008 19:48:29 +0100
>=20
>> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
>=20
> Hmmm...
>=20
> +static int enough_stack_space(void)
> +{
> +#ifdef CONFIG_STACK_GROWSUP
> +	return 0;
> +#else
> +	unsigned long free =3D (unsigned long)&free -
> +			     (unsigned long)end_of_stack(current);
> +	return free >=3D THREAD_SIZE/3 ;
> +#endif
> +}
> +
>=20
> This will always fail when we are on an interrupt stack,
> I think you'd want it to succeed in such a case.
>=20
> Can you agree that, at least to a point, this is getting a bit
> convoluted and perhaps adding more complexity than this optimization
> deserves? :-)
>=20
>=20

Yes, I do agree, mixing 'network' and 'mainline' in the same patch is g=
aranted=20
to be problematic.

We shall wait for 32 cpus machines before thinking about that :)

BTW, can loopback_xmit() be called on an interrupt stack ?

