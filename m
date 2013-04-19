From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 5/5] net/cpsw: redo rx skb allocation in rx path
Date: Fri, 19 Apr 2013 15:58:30 +0530
Message-ID: <51711C4E.5020704@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-6-git-send-email-bigeasy@linutronix.de> <516FDE20.2050605@ti.com> <516FE36B.9050801@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47125 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219Ab3DSK2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 06:28:47 -0400
In-Reply-To: <516FE36B.9050801@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 5:43 PM, Sebastian Andrzej Siewior wrote:
> On 04/18/2013 01:50 PM, Mugunthan V N wrote:
>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>> b/drivers/net/ethernet/ti/cpsw.c
>>> index 559b020..f684e9b 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -469,43 +469,36 @@ void cpsw_tx_handler(void *token, int len, int
> <snip>
>>> -    if (unlikely(!netif_running(ndev))) {
>>> -        if (skb)
>>> -            dev_kfree_skb_any(skb);
>>> -        return;
>>> +    } else {
>>> +        priv->stats.rx_dropped++;
>>> +        new_skb = skb;
>> Why you want to drop a successfully received packet as you memory alloc
>> failed?
>> Let the stack get it processed and there after you can continue with one
>> less
>> rx skb
> Because, as I wrote, if this continues you end up without rx skbs.
> However, if you if you are under memory pressure it is possible that
> other callers in the stack have the same problem.
>
I had gone through some other drivers and found that this patch is valid 
so add

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
