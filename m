From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/4] net: Add skb_headers_offset_update helper
 function.
Date: Thu, 7 Mar 2013 21:40:25 -0800
Message-ID: <20130307214025.639c713c@nehalam.linuxnetplumber.net>
References: <1362698500-2411-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54379 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab3CHFk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 00:40:28 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so1043396pad.10
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 21:40:27 -0800 (PST)
In-Reply-To: <1362698500-2411-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Mar 2013 15:21:40 -0800
Pravin B Shelar <pshelar@nicira.com> wrote:

> +static void skb_headers_offset_update(struct sk_buff *skb, int off)
> +{
> +	/* {transport,network,mac}_header and tail are relative to skb->head */
> +	skb->transport_header += off;
> +	skb->network_header   += off;
> +	if (skb_mac_header_was_set(skb))
> +		skb->mac_header += off;
> +	skb->inner_transport_header += off;
> +	skb->inner_network_header += off;
> +}
> +

Won't this cause an unused function warning if NET_SKBUFF_DATA_USES_OFFSET is defined?
