From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] ravb: Add tx and rx clock internal delays
 mode of APSR
Date: Fri, 27 Jan 2017 20:13:43 +0300
Message-ID: <77488d7f-b94b-1053-7f55-2a16ee09c3c8@cogentembedded.com>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
 <57812c3f-3130-7141-c479-6beefb237907@cogentembedded.com>
 <20170127165123.GC7336@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170127165123.GC7336@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2017 07:51 PM, Simon Horman wrote:

>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch enables tx and rx clock internal delay modes (TDM and RDM).
>>>
>>> This is to address a failure in the case of 1Gbps communication using the
>>> by salvator-x board with the KSZ9031RNX phy. This has been reported to
>>> occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
>>>
>>> With this change APSR internal delay modes are enabled for
>>> "rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
>>>
>>> phy mode   | ASPR delay mode
>>> -----------+----------------
>>> rgmii-id   | TDM and RDM
>>> rgmii-rxid | RDM
>>> rgmii-txid | TDM
>>>
>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>>>
>>> ---
>>> v1 [Simon Horman]
>>> - Combined patches
>>> - Reworded changelog
>>>
>>> v0 [Kazuya Mizuguchi]
>> [...]
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
>>> index 89ac1e3f6175..9fb4c04c5885 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>> @@ -2016,6 +2039,9 @@ static int ravb_probe(struct platform_device *pdev)
>>> 	/* Request GTI loading */
>>> 	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
>>>
>>> +	/* Set APSR */
>>> +	ravb_set_delay_mode(ndev);
>>> +
>>> 	/* Allocate descriptor base address table */
>>> 	priv->desc_bat_size = sizeof(struct ravb_desc) * DBAT_ENTRY_NUM;
>>> 	priv->desc_bat = dma_alloc_coherent(ndev->dev.parent, priv->desc_bat_size,
>>> @@ -2152,6 +2178,9 @@ static int __maybe_unused ravb_resume(struct device *dev)
>>> 	/* Request GTI loading */
>>> 	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
>>>
>>> +	/* Set APSR */
>>> +	ravb_set_delay_mode(ndev);
>>> +
>>
>>    So far the pattern was to first check if gen != 2, then calling a gen3
>> specific function. I'd like to keep it, rather than checking in the function
>> itself.
>
> So you would like something like?
>
> 	/* Set APSR */
> 	if (priv->chip_id != RCAR_GEN2)
> 		 ravb_set_delay_mode(ndev);

    Yes (except the comment).

>
> That does not seem better to me but I can make it so if that is your
> preference.

    Yes, not better code-wise but more consistent.

MBR, Sergei
