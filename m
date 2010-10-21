From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 63/72] tproxy: allow non-local binds of IPv6 sockets if
 IP_TRANSPARENT is enabled
Date: Fri, 22 Oct 2010 06:07:49 +0900
Message-ID: <1287695269.2707.7.camel@takos>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
	 <1287674399-31455-64-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: bazsi@balabit.hu, hidden@balabit.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-64-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2010-10-21, kaber@trash.net wrote:
> From: Balazs Scheidler <bazsi@balabit.hu>
> 
> Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
>  net/ipv6/af_inet6.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 56b9bf2..4869797 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -343,7 +343,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			 */
>  			v4addr = LOOPBACK4_IPV6;
>  			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
> -				if (!ipv6_chk_addr(net, &addr->sin6_addr,
> +				if (!inet->transparent &&
> +				    !ipv6_chk_addr(net, &addr->sin6_addr,
>  						   dev, 0)) {
>  					err = -EADDRNOTAVAIL;
>  					goto out_unlock;

Sorry, NAK.

http://kerneltrap.org/mailarchive/linux-netdev/2010/7/5/6280572

--yoshfuji

