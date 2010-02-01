From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 09:51:49 +0100
Message-ID: <1265014309.2848.7.camel@edumazet-laptop>
References: <20100201080256.4084.30962.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51256 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab0BAIvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 03:51:52 -0500
In-Reply-To: <20100201080256.4084.30962.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 02:59 -0500, Amerigo Wang a =C3=A9=
crit :
> Currently, we can only get TCP send buffer size by
> getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
> for the tools like netstat or ss to read.
>=20
> Show TCP send buffer size via netlink NETLINK_INET_DIAG.
>=20
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David Miller <davem@davemloft.net>
>=20
> ---
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7fee8a4..46768de 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -136,6 +136,7 @@ struct tcp_info {
>  	__u32	tcpi_ato;
>  	__u32	tcpi_snd_mss;
>  	__u32	tcpi_rcv_mss;
> +	__u32	tcpi_sndbuf;
> =20
>  	__u32	tcpi_unacked;
>  	__u32	tcpi_sacked;

You cannot change tcp_info like this, this structure is used by some
programs, and they are going to break badly.



