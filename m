From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after
 netdev_rx_handler_unregister
Date: Wed, 22 May 2013 19:04:08 -0700
Message-ID: <1369274648.3301.378.camel@edumazet-glaptop>
References: <519D77A3.7040003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:39453 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757158Ab3EWCEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 22:04:11 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so2311951pbb.8
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 19:04:10 -0700 (PDT)
In-Reply-To: <519D77A3.7040003@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 09:57 +0800, dingtianhong wrote:
> commit 00cfec3 (net: add a synchronize_net() in netdev_rx_handler_unregister())
> add a synchronize_net() in netdev_rx_handler_unregister() to guarantee the
> rx_handler is NULL when rx_handler_data is a non NULL in rcu_read_lock().
> 
> so the caller should not use netdev_rx_handler_unregister in atomic as it may
> schedule and sleep, the bonding release met the problem.
> 
> the commit fcd99434f (bonding: get netdev_rx_handler_unregister out of locks)
> fix the bug in bond release, but there is no action to guarantee the
> rx_handler_data is NULL when bond release, so add synchronize_net() behind
> netdev_rx_handler_unregister() to guarantee it.
> 
> This patch adds more comments to netdev_rx_handler_unregister(), as its more
> reasonable.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 ++
>  net/core/dev.c                  | 3 +++
>  2 files changed, 5 insertions(+)


I NACK this patch. This makes absolutely no sense to me.
