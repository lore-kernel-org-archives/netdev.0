From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sky2: Fix shutdown crash
Date: Fri, 18 Nov 2016 13:41:09 -0500 (EST)
Message-ID: <20161118.134109.1491291521879435264.davem@davemloft.net>
References: <1479395665-27784-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlindner@marvell.com,
        stephen@networkplumber.org, Sudeep.Holla@arm.com
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752961AbcKRSlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:41:13 -0500
In-Reply-To: <1479395665-27784-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Thu, 17 Nov 2016 09:14:25 -0600

> The sky2 frequently crashes during machine shutdown with:
> 
> sky2_get_stats+0x60/0x3d8 [sky2]
> dev_get_stats+0x68/0xd8
> rtnl_fill_stats+0x54/0x140
> rtnl_fill_ifinfo+0x46c/0xc68
> rtmsg_ifinfo_build_skb+0x7c/0xf0
> rtmsg_ifinfo.part.22+0x3c/0x70
> rtmsg_ifinfo+0x50/0x5c
> netdev_state_change+0x4c/0x58
> linkwatch_do_dev+0x50/0x88
> __linkwatch_run_queue+0x104/0x1a4
> linkwatch_event+0x30/0x3c
> process_one_work+0x140/0x3e0
> worker_thread+0x60/0x44c
> kthread+0xdc/0xf0
> ret_from_fork+0x10/0x50
> 
> This is caused by the sky2 being called after it has been shutdown.
> A previous thread about this can be found here:
> 
> https://lkml.org/lkml/2016/4/12/410
> 
> An alternative fix is to assure that IFF_UP gets cleared by
> calling dev_close() during shutdown. This is similar to what the
> bnx2/tg3/xgene and maybe others are doing to assure that the driver
> isn't being called following _shutdown().
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Applied and queued up for -stable, thanks.
