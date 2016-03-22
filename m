From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 4/5] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Tue, 22 Mar 2016 20:47:02 +0100
Message-ID: <877fgue1mx.fsf@rasmusvillemoes.dk>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
	<1455048677-19882-5-git-send-email-linux@rasmusvillemoes.dk>
	<8737s0d7iz.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Girish K S <ks.giri@samsung.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737s0d7iz.fsf@rasmusvillemoes.dk> (Rasmus Villemoes's message
	of "Tue, 08 Mar 2016 21:44:20 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ping^2

On Tue, Mar 08 2016, Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> ping
>
> On Tue, Feb 09 2016, Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:
>
>> We need to use post-decrement to ensure that irq_dispose_mapping is
>> also called on priv->rxq[0]->irq_no; moreover, if one of the above for
>> loops failed already at i==0 (so we reach one of these labels with
>> that value of i), we'll enter an essentially infinite loop of
>> out-of-bounds accesses.
>>
>> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>> ---
>>  drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
>> index b02eed12bfc5..73427e29df2a 100644
>> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
>> +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
>> @@ -155,11 +155,11 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
>>  	return 0;
>>  
>>  err_rx_irq_unmap:
>> -	while (--i)
>> +	while (i--)
>>  		irq_dispose_mapping(priv->rxq[i]->irq_no);
>>  	i = SXGBE_TX_QUEUES;
>>  err_tx_irq_unmap:
>> -	while (--i)
>> +	while (i--)
>>  		irq_dispose_mapping(priv->txq[i]->irq_no);
>>  	irq_dispose_mapping(priv->irq);
>>  err_drv_remove:
