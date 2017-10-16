From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: only update __use and lastusetime once
 per jiffy at most
Date: Mon, 16 Oct 2017 21:09:02 +0100 (WEST)
Message-ID: <20171016.210902.1215255184435565936.davem@davemloft.net>
References: <20171013220807.90366-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com,
        pabeni@redhat.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754127AbdJPUJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:09:04 -0400
In-Reply-To: <20171013220807.90366-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 13 Oct 2017 15:08:07 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In order to not dirty the cacheline too often, we try to only update
> dst->__use and dst->lastusetime at most once per jiffy.
> As dst->lastusetime is only used by ipv6 garbage collector, it should
> be good enough time resolution.
> And __use is only used in ipv6_route_seq_show() to show how many times a
> dst has been used. And as __use is not atomic_t right now, it does not
> show the precise number of usage times anyway. So we think it should be
> OK to only update it at most once per jiffy.
> 
> According to my latest syn flood test on a machine with intel Xeon 6th
> gen processor and 2 10G mlx nics bonded together, each with 8 rx queues
> on 2 NUMA nodes:
> With this patch, the packet process rate increases from ~3.49Mpps to
> ~3.75Mpps with a 7% increase rate.
> 
> Note: dst_use() is being renamed to dst_hold_and_use() to better specify
> the purpose of the function.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@googl.com>

Also applied, thank you.
