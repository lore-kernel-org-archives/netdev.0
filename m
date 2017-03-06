From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv4: add support for ECMP hash policy
 choice
Date: Mon, 6 Mar 2017 09:24:37 -0700
Message-ID: <bbdd46d3-7981-9718-7a93-249eacbe1a3b@cumulusnetworks.com>
References: <1488812370-24800-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34023 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753771AbdCFQYp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 11:24:45 -0500
Received: by mail-pg0-f51.google.com with SMTP id 77so23671731pgc.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 08:24:44 -0800 (PST)
In-Reply-To: <1488812370-24800-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/17 7:59 AM, Nikolay Aleksandrov wrote:
> diff --git a/include/net/route.h b/include/net/route.h
> index c0874c87c173..77a5c613a290 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -113,13 +113,12 @@ struct in_device;
>  int ip_rt_init(void);
>  void rt_cache_flush(struct net *net);
>  void rt_flush_dev(struct net_device *dev);
> -struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp,
> -					  int mp_hash);
> +struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *flp);
>  
>  static inline struct rtable *__ip_route_output_key(struct net *net,
>  						   struct flowi4 *flp)
>  {
> -	return __ip_route_output_key_hash(net, flp, -1);
> +	return __ip_route_output_key_hash(net, flp);
>  }
>  
>  struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,

The "_hash" variant was added by 79a131592dbb8. If the mp_hash arg is
removed, the "_hash" wrapper should be removed and go back to
__ip_route_output_key.
