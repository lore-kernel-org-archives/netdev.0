From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 15:42:10 +0100
Message-ID: <4F0D9FC2.2080204@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com> <4F0B7421.6050203@pengutronix.de> <4F0C0552.5080504@grandegger.com> <4F0C2F4A.20500@essax.com> <4F0D4FBA.1080108@essax.com> <4F0D58AE.7070601@pengutronix.de>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0D58AE.7070601@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

> Hello,
>
> On 01/11/2012 10:00 AM, Wolfgang Zarre wrote:
>>>> Please provide an extra patch for these unrelated changes. If we really
>>>> want to remove it.
>>>>
>>>
>>> Sure, this I can do.
>>>
>>
>> Ok, here the patch to remove:
>
> Looks good, please add a patch description and put in a patch series
> together with the spinlock patch (see other mail).

Thanks, also for the additional hints.

It might be that I let this patch for now until clarified if we
should remove or not.

>
> Marc
>
>> --------------------------------------------------------
>> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
>> index 2d12f89..dad6707 100644
>> --- a/drivers/net/can/cc770/cc770.c
>> +++ b/drivers/net/can/cc770/cc770.c
>> @@ -460,15 +460,6 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff
>> *skb, struct net_device *dev)
>>
>>       stats->tx_bytes += dlc;
>>
>> -
>> -    /*
>> -     * HM: We had some cases of repeated IRQs so make sure the
>> -     * INT is acknowledged I know it's already further up, but
>> -     * doing again fixed the issue
>> -     */
>> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
>> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>> -
>>       return NETDEV_TX_OK;
>>   }
>>
>> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct net_device
>> *dev, unsigned int o)
>>       /* Nothing more to send, switch off interrupts */
>>       cc770_write_reg(priv, msgobj[mo].ctrl0,
>>               MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
>> -    /*
>> -     * We had some cases of repeated IRQ so make sure the
>> -     * INT is acknowledged
>> -     */
>> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
>> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>>
>>       stats->tx_packets++;
>>       can_get_echo_skb(dev, 0);
>> ----------------------------------------------------------
>
> Marc
>

Wolfgang
