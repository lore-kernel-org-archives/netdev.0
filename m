From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] pxa168_eth: fix mdiobus_scan() error check
Date: Sun, 1 May 2016 23:30:06 +0300
Message-ID: <5726674E.2030904@cogentembedded.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
 <6024241.YxM8l6DPJo@wasted.cogentembedded.com> <57262956.3060206@gmail.com>
 <57266638.6030704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33193 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbcEAUaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:30:10 -0400
Received: by mail-lf0-f49.google.com with SMTP id y84so169339165lfc.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:30:09 -0700 (PDT)
In-Reply-To: <57266638.6030704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2016 11:25 PM, Sergei Shtylyov wrote:

>>> Since mdiobus_scan() returns either an error code or NULL on error, the
>>> driver should check  for both,  not only for NULL, otherwise a crash is
>>> imminent...
>>>
>>> Reported-by: Arnd Bergmann <arnd@arndb.de>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>> The patch is against DaveM's 'net.git' repo.
>>>
>>>   drivers/net/ethernet/marvell/pxa168_eth.c |    2 ++
>>>   1 file changed, 2 insertions(+)
>>>
>>> Index: net/drivers/net/ethernet/marvell/pxa168_eth.c
>>> ===================================================================
>>> --- net.orig/drivers/net/ethernet/marvell/pxa168_eth.c
>>> +++ net/drivers/net/ethernet/marvell/pxa168_eth.c
>>> @@ -979,6 +979,8 @@ static int pxa168_init_phy(struct net_de
>>>           return 0;
>>>
>>>       pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
>>> +    if (IS_ERR(pep->phy))
>>> +        return PTR_ERR(pep->phy);
>>>       if (!pep->phy)
>>>           return -ENODEV;
>>
>> Should not this check be removed too and
>
>     That's my next move -- for now I'm fixing the existing bug in this driver
> only.

    In fact, it can't be removed yet as mdiobus_scan() may return NULL on 
other error path. There's certainly a space for improvements yet...
[...]

MBR, Sergei
