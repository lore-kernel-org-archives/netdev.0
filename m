From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/3 net-2.6.26] [IPV4]: Remove unnecessary check for opt->is_data in ip_options_compile.
Date: Tue, 4 Mar 2008 14:03:20 -0500
Message-ID: <200803041403.20414.paul.moore@hp.com>
References: <1204633289.16891.7.camel@iris.sw.ru> <1204633326-17397-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:4114 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757400AbYCDTDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 14:03:21 -0500
In-Reply-To: <1204633326-17397-1-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 March 2008 7:22:04 am Denis V. Lunev wrote:
> There is the only way to reach ip_options compile with opt != NULL:
>
> ip_options_get_finish
>     opt->is_data = 1;
>     ip_options_compile(opt, NULL)
>
> So, checking for is_data inside opt != NULL branch is not needed.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  net/ipv4/ip_options.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index baaedd9..d03eec6 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -267,8 +267,7 @@ int ip_options_compile(struct ip_options * opt,
> struct sk_buff * skb) optptr = iph + sizeof(struct iphdr);
>  		opt->is_data = 0;
>  	} else {
> -		optptr = opt->is_data ? opt->__data :
> -					(unsigned char *)&(ip_hdr(skb)[1]);
> +		optptr = opt->__data;
>  		iph = optptr - sizeof(struct iphdr);
>  	}

I personally think this patch should be combined with path #2; if we 
aren't going to honor the 'is_data' field we shouldn't give any callers 
false hope.

-- 
paul moore
linux security @ hp
