From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] tun: call dev_get_valid_name() before
 register_netdevice()
Date: Mon, 16 Oct 2017 21:04:47 +0100 (WEST)
Message-ID: <20171016.210447.1449711502806536612.davem@davemloft.net>
References: <20171013185853.21353-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avekceeb@gmail.com, jasowang@redhat.com,
        mst@redhat.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753103AbdJPUEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:04:50 -0400
In-Reply-To: <20171013185853.21353-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 13 Oct 2017 11:58:53 -0700

> register_netdevice() could fail early when we have an invalid
> dev name, in which case ->ndo_uninit() is not called. For tun
> device, this is a problem because a timer etc. are already
> initialized and it expects ->ndo_uninit() to clean them up.
> 
> We could move these initializations into a ->ndo_init() so
> that register_netdevice() knows better, however this is still
> complicated due to the logic in tun_detach().
> 
> Therefore, I choose to just call dev_get_valid_name() before
> register_netdevice(), which is quicker and much easier to audit.
> And for this specific case, it is already enough.
> 
> Fixes: 96442e42429e ("tuntap: choose the txq based on rxq")
> Reported-by: Dmitry Alexeev <avekceeb@gmail.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
