From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: remove duplicate add_device_randomness() call
Date: Wed, 17 May 2017 11:17:58 -0400 (EDT)
Message-ID: <20170517.111758.1634488202115561021.davem@davemloft.net>
References: <1495013006-3011-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdEQPSB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:18:01 -0400
In-Reply-To: <1495013006-3011-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed, 17 May 2017 17:23:26 +0800

> Since register_netdevice() already call add_device_randomness() and
> dev_set_mac_address() will call it after mac address change.
> It's not necessary to call at device UP.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

__dev_open() can (at least theroretically) do things which adjust the
MAC address, and therefore the add_device_randomness() call is
appropriate.

And even if ->ndo_open() implementations do not do so currently, I
do not want to prevent it from doing so.

I am not applying this patch, sorry.
