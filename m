From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 2/4] bql: Add tracking of inflight packets
Date: Wed, 31 Aug 2016 06:08:56 -0700
Message-ID: <1472648936.14381.313.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
         <1472601634-531498-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rick.jones2@hpe.com,
        kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32824 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934200AbcHaNI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 09:08:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id i6so2770397pfe.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 06:08:58 -0700 (PDT)
In-Reply-To: <1472601634-531498-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 17:00 -0700, Tom Herbert wrote:
> Add two fields to netdev_queue as head_cnt and tail_cnt. head_cnt is
> incremented for every sent packet in netdev_tx_sent_queue and tail_cnt
> is incremented by the number of packets in netdev_tx_completed_queue.
> So then the number of inflight packets for a queue is simply
> queue->head_cnt - queue->tail_cnt.
> 
> Add inflight_pkts to be reported in sys-fs.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/linux/netdevice.h |  4 ++++
>  net/core/net-sysfs.c      | 11 +++++++++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d122be9..487d1df 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -592,6 +592,8 @@ struct netdev_queue {
>  
>  #ifdef CONFIG_BQL
>  	struct dql		dql;
> +	unsigned int		head_cnt;
> +	unsigned int		tail_cnt;
>  #endif
>  } ____cacheline_aligned_in_smp;
>  

You probably should put these fields in the appropriate cache lines of
"struct dql" : It will provide better cache behavior and fill holes.
