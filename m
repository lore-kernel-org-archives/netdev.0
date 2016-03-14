From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/3] of_mdio: use IS_ERR_OR_NULL()
Date: Mon, 14 Mar 2016 21:52:00 +0300
Message-ID: <56E70850.5020602@cogentembedded.com>
References: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
 <2638820.ej0i0xi4Er@wasted.cogentembedded.com> <4173235.nHpIx7Ti2k@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34861 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbcCNSwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:52:21 -0400
Received: by mail-lb0-f172.google.com with SMTP id bc4so251815853lbc.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 11:52:04 -0700 (PDT)
In-Reply-To: <4173235.nHpIx7Ti2k@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2016 01:22 AM, Arnd Bergmann wrote:

>> IS_ERR_OR_NULL() is open coded in of_mdiobus_register_phy(), so just call
>> it directly...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> ---
>> Changes in version 2:
>> - removed the of_mdiobus_register_device() hunk;
>> - added the "Reviewed-by:" tag.
>>
>>   drivers/of/of_mdio.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> Index: net-next/drivers/of/of_mdio.c
>> ===================================================================
>> --- net-next.orig/drivers/of/of_mdio.c
>> +++ net-next/drivers/of/of_mdio.c
>> @@ -56,7 +56,7 @@ static int of_mdiobus_register_phy(struc
>>                  phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>>          else
>>                  phy = get_phy_device(mdio, addr, is_c45);
>> -       if (!phy || IS_ERR(phy))
>> +       if (IS_ERR_OR_NULL(phy))
>>                  return 1;
>>
>>          rc = irq_of_parse_and_map(child, 0);
>>
>>
>
> IS_ERR_OR_NULL() usually indicates that the code is wrong, or that
> an API has been misdesigned.
>
> Can you clarify in the changelog which one it is,

    The second. :-)

> or (better) change
> it so that 'phy' in this function is either NULL or IS_ERR() in case
> of an error but not both?

    I guess you meant to change get_phy_device() to not return NULL (and so 
only return the error codes, not both), am I correct?

> I think moving the 'if (problem) return 1' into the two if/else
> is a correct transformation that also makes it very clear what
> is going on here.

    Can be done too... it's not that I have much time for that many respins 
though. It all started with 1 little patch (this one). :-)

> 	Arnd

MBR, Sergei
