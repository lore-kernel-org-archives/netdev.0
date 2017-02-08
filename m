From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sit: fix a double free on error path
Date: Wed, 08 Feb 2017 13:12:59 -0500 (EST)
Message-ID: <20170208.131259.2256112727442196980.davem@davemloft.net>
References: <1486576933-25561-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdBHSNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:13:01 -0500
In-Reply-To: <1486576933-25561-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  8 Feb 2017 10:02:13 -0800

> Dmitry reported a double free in sit_init_net():
 ...
> This is because when tunnel->dst_cache init fails, we free dev->tstats
> once in ipip6_tunnel_init() and twice in sit_init_net(). This looks
> redundant but its ndo_uinit() does not seem enough to clean up everything
> here. So avoid this by setting dev->tstats to NULL after the first free,
> at least for -net.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Good catch, applied and queued up for -stable, thanks!
