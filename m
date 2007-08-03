From: Tejun Heo <teheo@suse.de>
Subject: Re: [patch 2/5][RFC] Update net core to use devres.
Date: Fri, 03 Aug 2007 18:13:29 +0900
Message-ID: <46B2F1B9.9010605@suse.de>
References: <20070802224527.GD5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brandon Philips <bphilips@suse.de>
To: Brandon Philips <brandon@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jericho.provo.novell.com ([137.65.248.124]:54889 "EHLO
	jericho.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756698AbXHCJNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:13:47 -0400
In-Reply-To: <20070802224527.GD5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static inline void * register_netdev_devres(struct device *gendev,
> +						struct net_device *dev)
> +{
> +	struct net_device **p;
> +
> +	/* 0 size because we don't need it. The net_device is already alloc'd
> +	 * in alloc_netdev_mq.  We can't use devm_kzalloc in alloc_netdeev_mq
> +	 * because a net_device cannot be free'd directly as it can be a
> +	 * kobject.  See free_netdev.
> +	 */
> +	p = devres_alloc(devm_free_netdev, 0, GFP_KERNEL);

s/0/sizeof(*p)/

-- 
tejun
