From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 5/5] net/cpsw: redo rx skb allocation in rx path
Date: Thu, 18 Apr 2013 14:13:31 +0200
Message-ID: <516FE36B.9050801@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-6-git-send-email-bigeasy@linutronix.de> <516FDE20.2050605@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44314 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030Ab3DRMNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:13:33 -0400
In-Reply-To: <516FDE20.2050605@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2013 01:50 PM, Mugunthan V N wrote:
>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 559b020..f684e9b 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -469,43 +469,36 @@ void cpsw_tx_handler(void *token, int len, int
<snip>
>> -    if (unlikely(!netif_running(ndev))) {
>> -        if (skb)
>> -            dev_kfree_skb_any(skb);
>> -        return;
>> +    } else {
>> +        priv->stats.rx_dropped++;
>> +        new_skb = skb;
> Why you want to drop a successfully received packet as you memory alloc
> failed?
> Let the stack get it processed and there after you can continue with one
> less
> rx skb

Because, as I wrote, if this continues you end up without rx skbs.
However, if you if you are under memory pressure it is possible that
other callers in the stack have the same problem.

> 
> Regards
> Mugunthan V N

Sebastian
