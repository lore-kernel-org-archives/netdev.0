From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] IPV4: add raw drops counter
Date: Tue, 13 Nov 2007 12:11:17 +0100
Message-ID: <47398655.4060400@cosmosbay.com>
References: <47397514.2070002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:13253 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690AbXKMLLU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:11:20 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf1908.orange.fr (SMTP Server) with ESMTP id B6D4E1C0009A
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 12:11:19 +0100 (CET)
In-Reply-To: <47397514.2070002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wang Chen a =C3=A9crit :
> Add raw drops counter for IPv4 in /proc/net/raw .
>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  include/net/sock.h |    2 ++
>  net/core/sock.c    |    1 +
>  net/ipv4/raw.c     |   16 +++++++++-------
>  3 files changed, 12 insertions(+), 7 deletions(-)
>
> diff -Nurp linux-2.6.24-rc2.org/include/net/sock.h linux-2.6.24-rc2/i=
nclude/net/sock.h
> --- linux-2.6.24-rc2.org/include/net/sock.h	2007-11-09 16:37:08.00000=
0000 +0800
> +++ linux-2.6.24-rc2/include/net/sock.h	2007-11-13 15:19:20.000000000=
 +0800
> @@ -156,6 +156,7 @@ struct sock_common {
>    *	@sk_prot_creator: sk_prot of original sock creator (see ipv6_set=
sockopt, IPV6_ADDRFORM for instance)
>    *	@sk_err: last error
>    *	@sk_err_soft: errors that don't cause failure but are the cause =
of a persistent failure not just 'timed out'
> +  *	@sk_drops: raw drops counter
>    *	@sk_ack_backlog: current listen backlog
>    *	@sk_max_ack_backlog: listen backlog set in listen()
>    *	@sk_priority: %SO_PRIORITY setting
> @@ -239,6 +240,7 @@ struct sock {
>  	rwlock_t		sk_callback_lock;
>  	int			sk_err,
>  				sk_err_soft;
> +	atomic_t		sk_drops;
>  =20
This doesnt need an atomic_t , just an 'unsigned int' is OK, since=20
sock_queue_rcv_skb() is called on a locked socket.

Also, I suggest doing the sk_drops increment in sock_queue_rcv_skb() so=
=20
that it can be used for other sockets as well ?

I like having this counter per socket, but only if an application can=20
retrieve its value with a getsockopt() call, dont you think ?

getsockopt(sock, SOL_SOCKET, SO_DROPSCNT, &val, &vallen);





