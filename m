From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] bridge: add some missing __rcu marks
Date: Wed, 13 Feb 2013 22:39:35 -0800
Message-ID: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
References: <1360822350-26882-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:32844 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab3BNGjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 01:39:51 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so959227dae.17
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 22:39:51 -0800 (PST)
In-Reply-To: <1360822350-26882-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2013 14:12:30 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> 
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 6d314c4..0f115ba 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -328,7 +328,7 @@ extern void br_dev_delete(struct net_device *dev, struct list_head *list);
>  extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
>  			       struct net_device *dev);
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
> +static inline struct netpoll_info __rcu *br_netpoll_info(struct net_bridge *br)
>  {
>  	return br->dev->npinfo;
>  }


This doesn't seem right since there is no rcu_dereference() here.
