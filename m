From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/5] net/cpsw: don't continue if we miss to allocate rx
 skbs
Date: Fri, 19 Apr 2013 16:10:10 +0530
Message-ID: <51711F0A.50204@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-3-git-send-email-bigeasy@linutronix.de> <516FDDEE.6030906@ti.com> <516FE26C.5040601@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:48101 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929Ab3DSKkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 06:40:20 -0400
In-Reply-To: <516FE26C.5040601@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 5:39 PM, Sebastian Andrzej Siewior wrote:
> On 04/18/2013 01:50 PM, Mugunthan V N wrote:
>
>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>> b/drivers/net/ethernet/ti/cpsw.c
>>> index e2ba702..3b22a36 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -912,14 +912,16 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>>                struct sk_buff *skb;
>>>                  ret = -ENOMEM;
>>> -            skb = netdev_alloc_skb_ip_align(priv->ndev,
>>> -                            priv->rx_packet_max);
>>> +            skb = __netdev_alloc_skb_ip_align(priv->ndev,
>>> +                    priv->rx_packet_max, GFP_KERNEL);
>>>                if (!skb)
>>> -                break;
>>> +                goto err_cleanup;
>>>                ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
>>>                        skb_tailroom(skb), 0, GFP_KERNEL);
>>> -            if (WARN_ON(ret < 0))
>>> -                break;
>>> +            if (ret < 0) {
>>> +                kfree_skb(skb);
>>> +                goto err_cleanup;
>> Why you need to close the device even you have some skb allocated and
>> submitted successfully. Can allow the device to continue with lower
>> performance
> Because this should not happen. If you run out-of-memory because an
> application is going crazy than you won't have much anyway. If you
> configured too much skbs then this should be fixed as well.
>
But i am seeing most of the drivers allowing to open the device with lesser
rx skb count? But i don't know where this has been changed recently, may
be some other network experts can comment on this.

Regards
Mugunthan V N
