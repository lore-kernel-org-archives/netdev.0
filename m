From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6] can: Fix raw_getname() leak
Date: Fri, 07 Aug 2009 08:31:59 +0200
Message-ID: <4A7BCA5F.9050102@hartkopp.net>
References: <4A7BC938.8010504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:52971 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbZHGGcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 02:32:07 -0400
In-Reply-To: <4A7BC938.8010504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> raw_getname() can leak 10 bytes of kernel memory to user
> 
> (two bytes hole between can_family and can_ifindex,
> 8 bytes at the end of sockaddr_can structure)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

Thanks Eric!

> ---
> diff --git a/net/can/raw.c b/net/can/raw.c
> index f4cc445..db3152d 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -401,6 +401,7 @@ static int raw_getname(struct socket *sock, struct sockaddr *uaddr,
>  	if (peer)
>  		return -EOPNOTSUPP;
>  
> +	memset(addr, 0, sizeof(*addr));
>  	addr->can_family  = AF_CAN;
>  	addr->can_ifindex = ro->ifindex;
>  

