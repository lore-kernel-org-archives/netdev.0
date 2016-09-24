From: Eric Nelson <eric@nelint.com>
Subject: Re: [PATCH 0/3] net: fec: updates to align IP header
Date: Sat, 24 Sep 2016 08:29:10 -0700
Message-ID: <d4890f27-835f-f839-5225-366b3c87be07@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <AM4PR0401MB2260BDF848F89A445B1D013BFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33091 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbcIXP3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 11:29:13 -0400
Received: by mail-pf0-f169.google.com with SMTP id 21so51340778pfy.0
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 08:29:12 -0700 (PDT)
In-Reply-To: <AM4PR0401MB2260BDF848F89A445B1D013BFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2016 08:09 AM, Andy Duan wrote:
> From: Eric Nelson <eric@nelint.com> Sent: Saturday, September 24, 2016 10:42 PM
>> To: netdev@vger.kernel.org
>> Cc: linux@arm.linux.org.uk; andrew@lunn.ch; Andy Duan
>> <fugang.duan@nxp.com>; otavio@ossystems.com.br;
>> edumazet@google.com; troy.kisky@boundarydevices.com;
>> davem@davemloft.net; u.kleine-koenig@pengutronix.de; Eric Nelson
>> <eric@nelint.com>
>> Subject: [PATCH 0/3] net: fec: updates to align IP header
>>
>> This patch series is the outcome of investigation into very high numbers of
>> alignment faults on kernel 4.1.33 from the linux-fslc
>> tree:
>>     https://github.com/freescale/linux-fslc/tree/4.1-1.0.x-imx
>>
>> The first two patches remove support for the receive accelerator (RACC)
>> from the i.MX25 and i.MX27 SoCs which don't support the function.
>>
>> The third patch enables hardware alignment of the ethernet packet payload
>> (and especially the IP header) to prevent alignment faults in the IP stack.
>>
>> Testing on i.MX6UL on the 4.1.33 kernel showed that this patch removed on
>> the order of 70k alignment faults during a 100MiB transfer using wget.
>>
>> Testing on an i.MX6Q (SABRE Lite) board on net-next (4.8.0-rc7) showed a
>> much more modest improvement from 10's of faults, and it's not clear why
>> that's the case.
>>
>> Eric Nelson (3):
>>   net: fec: remove QUIRK_HAS_RACC from i.mx25
>>   net: fec: remove QUIRK_HAS_RACC from i.mx27
>>   net: fec: align IP header in hardware
>>
>>  drivers/net/ethernet/freescale/fec_main.c | 15 ++++++++++++---
>>  1 file changed, 12 insertions(+), 3 deletions(-)
>>
>> --
>> 2.7.4
> I will investigate the diff between 4.1 and 4.8. Thanks.
> 

Thanks. Note that I'm not sure if the difference is 4.1 vs. 4.8 or
i.MX6UL vs. i.MX6Q.

> Acked-by: Fugang Duan <fugang.duan@nxp.com>
> 
