From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Thu, 03 Apr 2014 16:36:03 -0400 (EDT)
Message-ID: <20140403.163603.2057792710871114160.davem@davemloft.net>
References: <1396529125-1441-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaDCUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 16:34:30 -0400
In-Reply-To: <1396529125-1441-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  3 Apr 2014 20:45:25 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> if allocating memory for vlan_pcpu_stats failed, the device can not be operated
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This check seems to have been there since Eric Dumazet added precise
RX statistic accounting.

It looks unnecessary to me, Eric?

 ...
>  static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>  {
> +	struct vlan_pcpu_stats *p;
> +	u32 rx_errors = 0, tx_dropped = 0;
> +	int i;
>  
> -	if (vlan_dev_priv(dev)->vlan_pcpu_stats) {
