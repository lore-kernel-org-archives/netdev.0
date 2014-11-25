From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] sch_fq: segment too big GSO packets
Date: Tue, 25 Nov 2014 06:53:13 -0800
Message-ID: <1416927193.29427.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
	 <1416921892-4756-4-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:56520 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYOxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 09:53:15 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so626597iec.24
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 06:53:15 -0800 (PST)
In-Reply-To: <1416921892-4756-4-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 21:24 +0800, Yang Yingliang wrote:
> If a GSO packet cost more than 125ms to send, segment the
> packet and send individual segments.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_fq.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
> index ec6eff8..0119340 100644
> --- a/net/sched/sch_fq.c
> +++ b/net/sched/sch_fq.c
> @@ -423,6 +423,30 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return qdisc_drop(skb, sch);
>  	}
>  

I am opposed to this patch serie.

FQ is used at 40Gb speeds at Google, we can not afford doing such copies
in FQ at all.

If you believe packets are too big at this point, then you should fix
the provider of such packets.

Sorry.
