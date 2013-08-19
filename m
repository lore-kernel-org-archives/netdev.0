From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Mon, 19 Aug 2013 23:00:36 +0400
Message-ID: <52126B54.4080603@cogentembedded.com>
References: <5211F97B.4090209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:57296 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3HSTAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 15:00:35 -0400
Received: by mail-la0-f44.google.com with SMTP id eo20so3659673lab.31
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 12:00:34 -0700 (PDT)
In-Reply-To: <5211F97B.4090209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/19/2013 02:54 PM, Duan Jiong wrote:

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

> rfc 4861 says the Redirected Header option is optional, so
> the kernel should not drop the Redirect Message that has no
> Redirected Header option. In this patch, the function
> ip6_redirect_no_header() is introduced to deal with that
> condition.

> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
[...]

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index b70f897..9934b87 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1178,6 +1178,27 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
>   }
>   EXPORT_SYMBOL_GPL(ip6_redirect);
>   
> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif, u32 mark)
> +{
> +	const struct ipv6hdr *iph = (struct ipv6hdr *) skb_network_header(skb);
> +	struct rd_msg *msg = (struct rd_msg *)skb_transport_header(skb);

   Be consistent please: either put space after a typecast or not.

> +	struct dst_entry *dst;
> +	struct flowi6 fl6;

WBR, Sergei
