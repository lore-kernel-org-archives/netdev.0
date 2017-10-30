From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: display hw address of source machine during
 ipv6 DAD failure
Date: Mon, 30 Oct 2017 14:43:14 -0600
Message-ID: <2aa97226-9db7-e401-3e90-7c773e1e083b@gmail.com>
References: <1509395380-28057-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56162 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbdJ3UnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:43:17 -0400
Received: by mail-pg0-f68.google.com with SMTP id 15so12652980pgc.12
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:43:16 -0700 (PDT)
In-Reply-To: <1509395380-28057-1-git-send-email-vpai@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/17 2:29 PM, Vishwanath Pai wrote:
> This patch updates the error messages displayed in kernel log to include
> hwaddress of the source machine that caused ipv6 duplicate address
> detection failures.
> 
> Examples:
> 
> a) When we receive a NA packet from another machine advertising our
> address:
> 
> ICMPv6: NA: 34:ab:cd:56:11:e8 advertised our address 2601::2bb4 on eth0!

your example above does not agree with the format below. You have the
compressed IPv6 address, yet the format ...

> 
> b) When we detect DAD failure during address assignment to an interface:
> 
> IPv6: eth0: IPv6 duplicate address 2601::2b78 used by 34:ab:cd:56:11:e8
> detected!
> 
> Suggested-by: Igor Lubashev <ilubashe@akamai.com>
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> ---


> @@ -989,8 +990,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  		 */
>  		if (skb->pkt_type != PACKET_LOOPBACK)
>  			ND_PRINTK(1, warn,
> -				  "NA: someone advertises our address %pI6 on %s!\n",
> -				  &ifp->addr, ifp->idev->dev->name);
> +				  "NA: %pM advertised our address %pI6 on %s!\n",

... is uncompressed. Please make that '%pI6c' instead of pI6 in the line
above


> +				  eth_hdr(skb)->h_source, &ifp->addr, ifp->idev->dev->name);
>  		in6_ifa_put(ifp);
>  		return;
>  	}
