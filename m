From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] ipv6: fix the debug information in icmpv6_route_lookup
Date: Fri, 11 Jul 2014 15:45:42 +0900
Message-ID: <53BF8816.8010400@miraclelinux.com>
References: <1405060451-12633-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og115.obsmtp.com ([64.18.2.217]:59795 "HELO
	exprod7og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750768AbaGKGpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 02:45:45 -0400
Received: by mail-pa0-f41.google.com with SMTP id fb1so919690pad.28
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 23:45:44 -0700 (PDT)
In-Reply-To: <1405060451-12633-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> it should be "anycast destination", not "anycast source"
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv6/icmp.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index f6c84a6..481fd5a 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -334,7 +334,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
>   	 * anycast.
>   	 */
>   	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
> -		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast source\n");
> +		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast destination\n");
>   		dst_release(dst);
>   		return ERR_PTR(-EINVAL);
>   	}
> 

No.
It is used by icmp6_send() and it means icmp6_send() won't
send back to the original "anycast" source addresses.

--yoshfuji
