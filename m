From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Mon, 26 Jun 2006 19:04:15 +0200
Message-ID: <44A0138F.8050208@trash.net>
References: <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37040 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750816AbWFZRER
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 13:04:17 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060626145515.769648000@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Updating iif to the VLAN device helps keeping routing
> namespaces defined in case packets from multiple VLANs
> collapse on a single device again.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.git/net/8021q/vlan_dev.c
> ===================================================================
> --- net-2.6.git.orig/net/8021q/vlan_dev.c
> +++ net-2.6.git/net/8021q/vlan_dev.c
> @@ -156,6 +156,8 @@ int vlan_skb_recv(struct sk_buff *skb, s
>  		return -1;
>  	}
>  
> +	/* Make packets look like they have been received on the VLAN device */
> +	skb->iif = skb->dev->ifindex;
>  	skb->dev->last_rx = jiffies;

I know this was discussed before, but I can't remember the
exact outcome. Why don't we just unconditionally update iif
in netif_receive_skb()?

