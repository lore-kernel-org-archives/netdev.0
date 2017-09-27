From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/6] net: dsa: {e}dsa: set offload_fwd_mark on
 received packets
Date: Wed, 27 Sep 2017 12:46:35 -0700
Message-ID: <1c4ba973-91c0-ae81-1c4b-d0281f5c7517@gmail.com>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:45123 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdI0Tql (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 15:46:41 -0400
Received: by mail-wm0-f68.google.com with SMTP id q124so22165229wmb.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 12:46:40 -0700 (PDT)
In-Reply-To: <1506464764-12699-3-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 03:25 PM, Andrew Lunn wrote:
> The software bridge needs to know if a packet has already been bridged
> by hardware offload to ports in the same hardware offload, in order
> that it does not re-flood them, causing duplicates. This is
> particularly true for broadcast and multicast traffic which the host
> has requested.
> 
> By setting offload_fwd_mark in the skb the bridge will only flood to
> ports in other offloads and other netifs. Set this flag in the DSA and
> EDSA tag driver.

Is not there some kind of forwarding code/reason code being provided in
the EDSA/DSA tag that tell you why this packet was sent to the CPU in
the first place?

What is the impact on non-broadcast traffic, e.g: multicast and unicast?

Nit: I don't really have a solution on how to order patches, but until
the next 4 patches get in, I suppose we temporarily have broadcast
flooding by the bridge "broken"? Ordering in the opposite way would
probably result in an equally bad situation so...

> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> 
> v2
> --
> For the moment, do this in the tag drivers, not the generic code.
> Once we get more test results from other switches, maybe move it back
> again.
> ---
>  net/dsa/tag_dsa.c  | 1 +
>  net/dsa/tag_edsa.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
> index fbf9ca954773..ea6ada9d5016 100644
> --- a/net/dsa/tag_dsa.c
> +++ b/net/dsa/tag_dsa.c
> @@ -154,6 +154,7 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
>  	}
>  
>  	skb->dev = ds->ports[source_port].netdev;
> +	skb->offload_fwd_mark = 1;
>  
>  	return skb;
>  }
> diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
> index 76367ba1b2e2..a961b22a7018 100644
> --- a/net/dsa/tag_edsa.c
> +++ b/net/dsa/tag_edsa.c
> @@ -173,6 +173,7 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
>  	}
>  
>  	skb->dev = ds->ports[source_port].netdev;
> +	skb->offload_fwd_mark = 1;
>  
>  	return skb;
>  }
> 


-- 
Florian
