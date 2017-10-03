From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 1/3] bridge: add new BR_NEIGH_SUPPRESS port
 flag to suppress arp and nd flood
Date: Tue, 3 Oct 2017 11:29:48 -0700
Message-ID: <20171003112948.44d9cc56@xeon-e3>
References: <1507054876-16746-1-git-send-email-roopa@cumulusnetworks.com>
        <1507054876-16746-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com, bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:53916 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdJCS34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:29:56 -0400
Received: by mail-pf0-f176.google.com with SMTP id y24so1738338pfa.10
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:29:55 -0700 (PDT)
In-Reply-To: <1507054876-16746-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Oct 2017 11:21:14 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index 48fb174..7a50dc5 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -204,7 +204,8 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
>  		/* Do not flood to ports that enable proxy ARP */
>  		if (p->flags & BR_PROXYARP)
>  			continue;
> -		if ((p->flags & BR_PROXYARP_WIFI) &&
> +		if ((p->flags & BR_PROXYARP_WIFI ||
> +		     p->flags & BR_NEIGH_SUPPRESS) &&
>  		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
>  			continue;

Don;t you need additional paren here to avoid warnings.
Or do one mask:
		if ((p->flags & (BR_PROXYARP_WIFI | BR_NEIGH_SUPPRESS)) &&
 		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
  			continue;
