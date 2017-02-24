From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: Add support for IEEE 802.11 Proxy ARP for IPv6
Date: Fri, 24 Feb 2017 11:55:37 -0800
Message-ID: <20170224115537.160609db@xeon-e3>
References: <1487961581-20683-1-git-send-email-jouni@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jouni Malinen <jouni@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33848 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdBXTzp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:55:45 -0500
Received: by mail-pg0-f46.google.com with SMTP id 1so15189515pgi.1
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 11:55:45 -0800 (PST)
In-Reply-To: <1487961581-20683-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The concept is fine.

Please add some comments to the code about what is happening and why.
The proposed patch is too sparse and has no comments.


> +	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + sizeof(*msg) +
> +			ndisc_opt_addr_space(dev,
> +					     NDISC_NEIGHBOUR_ADVERTISEMENT) +
> +			tlen, GFP_ATOMIC);
> +	if (!skb)
> +		return;

Why not netdev_alloc_skb which takes care of padding and setting skb->dev? 

Rather than doing copy/paste of the code to generate a ND message, it would
be better to have one function in IPv6 code that handles that. That would keep
from having to fix code in two places in the future. Is there some way
to extend ndisc_send_na?
