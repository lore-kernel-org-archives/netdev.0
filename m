From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 5/9] tproxy: allow non-local binds of IPv6 sockets if
 IP_TRANSPARENT is enabled
Date: Wed, 20 Oct 2010 21:45:17 +0900
Message-ID: <4CBEE45D.2080201@linux-ipv6.org>
References: <20101020112118.6260.31618.stgit@este.odu> <20101020112118.6260.93956.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35996 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752296Ab0JTMpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 08:45:22 -0400
In-Reply-To: <20101020112118.6260.93956.stgit@este.odu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2010/10/20 20:21), KOVACS Krisztian wrote:
> From: Balazs Scheidler<bazsi@balabit.hu>
> 
> Signed-off-by: Balazs Scheidler<bazsi@balabit.hu>
> Signed-off-by: KOVACS Krisztian<hidden@balabit.hu>
> ---
>   net/ipv6/af_inet6.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 6022098..9480572 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -343,7 +343,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>   			 */
>   			v4addr = LOOPBACK4_IPV6;
>   			if (!(addr_type&  IPV6_ADDR_MULTICAST))	{
> -				if (!ipv6_chk_addr(net,&addr->sin6_addr,
> +				if (!inet->transparent&&  !ipv6_chk_addr(net,&addr->sin6_addr,
>   						   dev, 0)) {
>   					err = -EADDRNOTAVAIL;
>   					goto out_unlock;
> 
> 

As I wrote before in other thread, this does not seem sufficient --
well, it is sufficient to allow non-local bind, but before we're
allowing this, we need add checks of source address in sending side.

Regards,

--yoshfuji
