From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Thu, 13 Nov 2014 23:16:59 -0800
Message-ID: <1415949419.17262.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415946547-25811-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33370 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbaKNHRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 02:17:03 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so2684817iec.3
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 23:17:02 -0800 (PST)
In-Reply-To: <1415946547-25811-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-13 at 22:29 -0800, Mahesh Bandewar wrote:

> +int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	struct ipvl_port *port = ipvlan_port_get_rcu(ipvlan->phy_dev);
> +
> +	if (!port)
> +		goto out;
> +
> +	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
> +		goto out;
> +
> +	switch(port->mode) {
> +	case IPVLAN_MODE_L2:
> +		return ipvlan_xmit_mode_l2(skb, dev);
> +	case IPVLAN_MODE_L3:
> +		return ipvlan_xmit_mode_l3(skb, dev);
> +	}
> +
> +	/* Should not reach here */
> +	BUG();
> +out:
> +	return RX_HANDLER_ANOTHER;
> +}

RX_HANDLER_ANOTHER makes no sense here...

Also you are leaking skb.

kfree_skb(skb);
return NET_XMIT_DROP;
