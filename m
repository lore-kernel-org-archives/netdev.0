From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: [PATCH net 4/6] stmmac: Validate hwtstamp_config completely
 before applying it
Date: Tue, 19 Nov 2013 11:25:44 +0530
Message-ID: <CAJ3bTp6rjVxAfZWGY9-wALv8isCMfCZdJ8DfWgkqYwCGOD7HQA@mail.gmail.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
	<1384389821.29151.10.camel@bwh-desktop.uk.level5networks.com>
	<528AF66F.2060204@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36726 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab3KSFzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 00:55:45 -0500
Received: by mail-wi0-f169.google.com with SMTP id hj6so854100wib.4
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 21:55:44 -0800 (PST)
In-Reply-To: <528AF66F.2060204@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 10:56 AM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 11/14/2013 1:44 AM, Ben Hutchings wrote:
>>
>> stmmac_hwtstamp_ioctl() should validate all fields of hwtstamp_config
>> before making any changes.  Currently it sets the TX configuration
>> before validating the rx_filter field.
>>
>> Compile-tested only.
>
>
> Thx Ben for this patch.
>
> Rayagond, can you do any run-time tests?

I don't have HW now. But next week I will be getting GMAC 4.0, so I
can do similar changes in that driver and do run-time test.

>
> peppe
>
>
>>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 12 +++---------
>>   1 file changed, 3 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 8d4ccd35a016..8a7a23a84ac5 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -435,16 +435,9 @@ static int stmmac_hwtstamp_ioctl(struct net_device
>> *dev, struct ifreq *ifr)
>>         if (config.flags)
>>                 return -EINVAL;
>>
>> -       switch (config.tx_type) {
>> -       case HWTSTAMP_TX_OFF:
>> -               priv->hwts_tx_en = 0;
>> -               break;
>> -       case HWTSTAMP_TX_ON:
>> -               priv->hwts_tx_en = 1;
>> -               break;
>> -       default:
>> +       if (config.tx_type != HWTSTAMP_TX_OFF &&
>> +           config.tx_type != HWTSTAMP_TX_ON)
>>                 return -ERANGE;
>> -       }
>>
>>         if (priv->adv_ts) {
>>                 switch (config.rx_filter) {
>> @@ -576,6 +569,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device
>> *dev, struct ifreq *ifr)
>>                 }
>>         }
>>         priv->hwts_rx_en = ((config.rx_filter == HWTSTAMP_FILTER_NONE) ? 0
>> : 1);
>> +       priv->hwts_tx_en = config.tx_type == HWTSTAMP_TX_ON;
>>
>>         if (!priv->hwts_tx_en && !priv->hwts_rx_en)
>>                 priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
>>
>>
>
