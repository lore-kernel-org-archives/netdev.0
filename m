From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix increase rx_read_ptr
Date: Tue, 7 Oct 2014 15:40:09 +0900
Message-ID: <A2B48C43-2DFE-4D2F-9950-B834AE469F23@me.com>
References: <1412564726-40192-1-git-send-email-jaedon.shin@gmail.com> <5432C73E.90805@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1988\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:62494 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbaJGGkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 02:40:15 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so4609242pdi.10
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 23:40:15 -0700 (PDT)
In-Reply-To: <5432C73E.90805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the previous commit b629be5c8399d7c423b92135eb43a86c924d1cbc ("net: bcmgenet: check harder for out of memory conditions").

The previous commit has a problem that gets invalid dma_length_status by increased rx_read_ptr. And it should be increased after all goto refill.
 

> On Oct 7, 2014, at 1:45 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
> On 10/05/2014 08:05 PM, Jaedon Shin wrote:
>> The rx_read_ptr must increase after using it.
> 
> Your commit message is too terse, you need to explain why you think the
> current code is bad, and how your patch is fixing it.
> 
> One possible thing that I see is that we might be off by one in how we
> use the enet_cb versus how we read the HW packet descriptor.
> 
>> 
>> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
>> ---
>> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
>> 1 file changed, 3 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 5cc9cae..b47db5e 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -1282,9 +1282,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>> 
>> 		rxpktprocessed++;
>> 
>> -		priv->rx_read_ptr++;
>> -		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>> -
>> 		/* We do not have a backing SKB, so we do not have a
>> 		 * corresponding DMA mapping for this incoming packet since
>> 		 * bcmgenet_rx_refill always either has both skb and mapping or
>> @@ -1399,6 +1396,9 @@ refill:
>> 		err = bcmgenet_rx_refill(priv, cb);
>> 		if (err)
>> 			netif_err(priv, rx_err, dev, "Rx refill failed\n");
>> +
>> +		priv->rx_read_ptr++;
>> +		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>> 	}
>> 
>> 	return rxpktprocessed;
>> 
> 
