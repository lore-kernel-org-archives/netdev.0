From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 09:37:33 -0800
Message-ID: <20170124093733.5c27a079@xeon-e3>
References: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36618 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXRhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:37:43 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so51618095pfu.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 09:37:43 -0800 (PST)
In-Reply-To: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jan 2017 10:40:13 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

>  
> +/* return true if we should preserve skb nfct before calling ndo_start_xmit() */
> +static inline bool netif_needs_ct(struct net_device *dev)
> +{
> +	/* any kind of virtual device needs to preserve the ct entry */
> +	return dev->features & NETIF_F_LLTX;
> +}
> +

I am not sure I fully understand the problem, and this looks like a special case
hack. You are overloading meaning of LLTX flag in a new way.

If you must do it then code this in place, and put comment there.
The addition of accessor function just obscures the purpose.
