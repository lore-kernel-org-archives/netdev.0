From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skip genenerating uevents for network namespaces
 that are exiting
Date: Sat, 22 Oct 2016 17:00:04 -0400 (EDT)
Message-ID: <20161022.170004.211874574494014545.davem@davemloft.net>
References: <1477017986-18889-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754877AbcJVVAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 17:00:06 -0400
In-Reply-To: <1477017986-18889-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Thu, 20 Oct 2016 19:46:26 -0700

> @@ -1525,6 +1530,9 @@ void netdev_unregister_kobject(struct net_device *ndev)
>  {
>  	struct device *dev = &(ndev->dev);
>  
> +	if (!list_empty(&dev_net(ndev)->exit_list))
> +		dev->kobj.uevent_suppress = 1;
> +

Please use "dev_set_uevent_suppress(dev, 1);"
