From: walter harms <wharms@bfs.de>
Subject: Re: [patch] isdn: mISDN: set ->family in ->getname()
Date: Tue, 23 Apr 2013 09:40:07 +0200
Message-ID: <51763AD7.10102@bfs.de>
References: <20130423062414.GC15893@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:13959 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122Ab3DWHvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 03:51:04 -0400
In-Reply-To: <20130423062414.GC15893@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 23.04.2013 08:24, schrieb Dan Carpenter:
> The "maddr->family" variable was not set but instead it leaked stack
> information to userspace.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
> index 8b07f83..a838864 100644
> --- a/drivers/isdn/mISDN/socket.c
> +++ b/drivers/isdn/mISDN/socket.c
> @@ -578,6 +578,7 @@ data_sock_getname(struct socket *sock, struct sockaddr *addr,
>  	lock_sock(sk);
>  
>  	*addr_len = sizeof(*maddr);
> +	maddr->family = AF_ISDN;
>  	maddr->dev = _pms(sk)->dev->id;
>  	maddr->channel = _pms(sk)->ch.nr;
>  	maddr->sapi = _pms(sk)->ch.addr & 0xff;

just nitpicking ...
net/nfc/llcp/sock.c has a memset(..0,..) for the struct. Is this an options here also ?
(just to make sure everything is 0 in the beginning)
re,
 wh
