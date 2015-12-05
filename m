From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH net-next] ravb: ptp: Add CONFIG mode support
Date: Sat, 5 Dec 2015 19:01:40 +0900
Message-ID: <CAH1o70+n7m+4rmVvTbi9VNBknzV9s_04dsADhJ4RSkuC07ti7A@mail.gmail.com>
References: <1448989479-11594-1-git-send-email-ykaneko0929@gmail.com>
	<5660AF89.1010008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:36360 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbbLEKBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 05:01:41 -0500
In-Reply-To: <5660AF89.1010008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

Thanks for your review.

2015-12-04 6:09 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/01/2015 08:04 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch makes PTP support active in CONFIG mode on R-Car Gen3.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>
>> This patch is based on the master branch of David Miller's next networking
>> tree.
>>
>>   drivers/net/ethernet/renesas/ravb.h      |  1 +
>>   drivers/net/ethernet/renesas/ravb_main.c | 33
>> +++++++++++++++++++++++++++-----
>>   2 files changed, 29 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb.h
>> b/drivers/net/ethernet/renesas/ravb.h
>> index f9dee74..9fbe92a 100644
>> --- a/drivers/net/ethernet/renesas/ravb.h
>> +++ b/drivers/net/ethernet/renesas/ravb.h
>> @@ -206,6 +206,7 @@ enum CCC_BIT {
>>         CCC_OPC_RESET   = 0x00000000,
>>         CCC_OPC_CONFIG  = 0x00000001,
>>         CCC_OPC_OPERATION = 0x00000002,
>> +       CCC_GAC         = 0x00000080,
>
>
>    I'd have added a comment that it's gen3 specific.
>
> [...]
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index 990dc55..293046d 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>
>> @@ -1814,6 +1825,10 @@ static int ravb_probe(struct platform_device *pdev)
>>         /* Initialise HW timestamp list */
>>         INIT_LIST_HEAD(&priv->ts_skb_list);
>>
>> +       /* Initialise PTP Clock driver */
>> +       if (chip_id != RCAR_GEN2)
>> +               ravb_ptp_init(ndev, pdev);
>> +
>>         /* Debug message level */
>>         priv->msg_enable = RAVB_DEF_MSG_ENABLE;
>>
>> @@ -1855,6 +1870,10 @@ out_napi_del:
>>   out_dma_free:
>>         dma_free_coherent(ndev->dev.parent, priv->desc_bat_size,
>> priv->desc_bat,
>>                           priv->desc_bat_dma);
>> +
>> +       /* Stop PTP Clock driver */
>> +       if (chip_id != RCAR_GEN2)
>> +               ravb_ptp_stop(ndev);
>
>
>    This is clearly misplaced.

It's my fault.

>
> [...]
>
> MBR, Sergei
>

Regards,
Kaneko
