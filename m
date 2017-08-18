From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: rcu lock and preempt disable missing
 around generic xdp
Date: Fri, 18 Aug 2017 16:04:59 -0700 (PDT)
Message-ID: <20170818.160459.1790177371740031034.davem@davemloft.net>
References: <20170816183319.7709.87749.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdHRXFA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:05:00 -0400
In-Reply-To: <20170816183319.7709.87749.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 16 Aug 2017 11:33:19 -0700

> do_xdp_generic must be called inside rcu critical section with preempt
> disabled to ensure BPF programs are valid and per-cpu variables used
> for redirect operations are consistent. This patch ensures this is true
> and fixes the splat below.
> 
> The netif_receive_skb_internal() code path is now broken into two rcu
> critical sections. I decided it was better to limit the preempt_enable/disable
> block to just the xdp static key portion and the fallout is more
> rcu_read_lock/unlock calls. Seems like the best option to me.
 ...
> Fixes: d445516966dc ("net: xdp: support xdp generic on virtual devices")
> Fixes: b5cdae3291f7 ("net: Generic XDP")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

John you'll need to respin this as these code blocks have changed.
