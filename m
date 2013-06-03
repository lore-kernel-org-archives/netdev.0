From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next] net: fec: add fallback to random MAC address
Date: Mon, 03 Jun 2013 15:33:26 +0400
Message-ID: <51AC7F06.5070805@cogentembedded.com>
References: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de> <51AC7E46.4010708@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Pavel Machek <pavel@denx.de>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:38013 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3FCLdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 07:33:31 -0400
Received: by mail-lb0-f171.google.com with SMTP id v5so892920lbc.16
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 04:33:29 -0700 (PDT)
In-Reply-To: <51AC7E46.4010708@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-06-2013 15:30, I wrote:

>> If no valid MAC address could be obtained from the hardware,
>> fall back to a randomly generated one.

>> Signed-off-by: Pavel Machek <pavel@denx.de>
>> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
>> ---
>>   drivers/net/ethernet/freescale/fec_main.c | 12 ++++++++++++
>>   1 file changed, 12 insertions(+)

>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index 927f4c6..0063761 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1039,6 +1039,18 @@ static void fec_get_mac(struct net_device *ndev)
>>           iap = &tmpaddr[0];
>>       }
>>
>> +    /*
>> +     * 5) random mac address
>> +     */
>> +    if (!is_valid_ether_addr(iap)) {
>> +        /* Report it and use a random ethernet address instead */
>> +        netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
>> +        eth_hw_addr_random(ndev);
>> +        netdev_info(ndev, "Using random MAC address: %pM\n",
>> +                ndev->dev_addr);
>> +        return;
>> +    }
>> +
>>       memcpy(ndev->dev_addr, iap, ETH_ALEN);

>     This was you'll copy an invalid address over the random one again.

   Oh, sorry, have overlooked *return*... :-<

WBR, Sergei
