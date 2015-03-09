From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/4] net: refactor IPv4 and IPv6 fragmentation
 APIs
Date: Mon, 09 Mar 2015 08:07:38 -0700
Message-ID: <1425913658.8261.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
	 <1425888098-21875-4-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:44581 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbbCIPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 11:07:40 -0400
Received: by iery20 with SMTP id y20so10663646ier.11
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 08:07:40 -0700 (PDT)
In-Reply-To: <1425888098-21875-4-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 01:01 -0700, Andy Zhou wrote:

> +int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
> +{
> +	struct iphdr *iph;
> +	struct net_device *dev;
> +	unsigned int mtu, ll_rs;
> +	struct rtable *rt = skb_rtable(skb);


For better readability, we prefer to order local variables in decreasing
lengths :

->

+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+{
+       struct rtable *rt = skb_rtable(skb);
+       unsigned int mtu, ll_rs;
+       struct net_device *dev;
+       struct iphdr *iph;
