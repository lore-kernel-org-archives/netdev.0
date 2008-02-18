From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 16:19:40 +0100
Message-ID: <47B9A20C.10304@trash.net>
References: <20080215104804.9870.15722.stgit@one>	 <20080215.025855.202184003.davem@davemloft.net> <1203097370.21308.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bruno@thinktube.com,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:61693 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756347AbYBRPTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 10:19:49 -0500
In-Reply-To: <1203097370.21308.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Fri, 2008-02-15 at 02:58 -0800, David Miller wrote:
>> From: Bruno Randolf <bruno@thinktube.com>
>> Date: Fri, 15 Feb 2008 19:48:05 +0900
>>> is there any chance to include a macro like this for printing mac
>> addresses?
>>> its advantage is that it can be used without the need to declare
>> buffers for
>>> print_mac(), for example:
>> We specifically removed this sort of thing, please don't
>> add it back.

Why?

> @@ -404,11 +405,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	pr_debug("%s: about to send skb: %p to dev: %s\n",
>  		__FUNCTION__, skb, skb->dev->name);
> -	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
> -		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
> -		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
> -		 veth->h_source[0], veth->h_source[1], veth->h_source[2],
> -		 veth->h_source[3], veth->h_source[4], veth->h_source[5],
> +	pr_debug("  %s %s %4hx %4hx %4hx\n",
> +		 print_mac(mac, veth->h_dest), print_mac(mac2, veth->h_source),


This results in print_mac getting called twice per packet even without
debugging. Whats the problem with MAC_FMT?
