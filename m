From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next 3/4] net: refactor IPv4 and IPv6 fragmentation
 APIs
Date: Mon, 9 Mar 2015 18:25:59 +0900
Message-ID: <20150309092557.GB13498@vergenet.net>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
 <1425888098-21875-4-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:42994 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbbCIJ0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:26:09 -0400
Received: by pdbfl12 with SMTP id fl12so62446401pdb.9
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 02:26:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1425888098-21875-4-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 01:01:37AM -0700, Andy Zhou wrote:
> Both ip_fragment() and ip6_fragment() APIs assume skb has an
> attached netdev device, from which the MTU size can be derived.
> However, skbs incoming from OVS vports do not have an attached
> netdev device.
> 
> This patch splits the original function into two parts: The core
> fragmentation logic is now provided by
> ip_fragment_mtu()/ip6_fragment_mut().
> 
> The original APIs are kept as is. Their implementation now calls
> the new APIs. Any information derived from the attached netdev
> device is first derived in the original APIs and passed into the
> new APIs.
> 
> In addition, The call back output function into the new APIs now
> accepts two arguments: a skb and an application specific pointer,
> which specifies additional information not directly associated
> with skb, such as OVS flow, to the output function.

I suggest handling that portion of the change separately.
It doesn't seem nearly as well defined as the rest of the change.
And cast below seems somewhat undesirable to me.

[snip]

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index a7aea20..b85fd34 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c

> +	return ip_fragment_mtu(skb, mtu, ll_rs, NULL, dev,
> +			(int (*)(struct sk_buff *, void *output_arg))output);
> +}
>  EXPORT_SYMBOL(ip_fragment);
