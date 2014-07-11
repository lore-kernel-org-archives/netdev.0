From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Question about settings array in phy.c
Date: Fri, 11 Jul 2014 10:21:09 -0700
Message-ID: <CAGVrzcbrasYjNMqVVjVMdeM+Lv4w+s-=NM4XM_oB-mYw_a+7bw@mail.gmail.com>
References: <53C007E3.4010009@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:55253 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246AbaGKRVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 13:21:50 -0400
Received: by mail-oa0-f49.google.com with SMTP id eb12so1515483oac.22
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 10:21:49 -0700 (PDT)
In-Reply-To: <53C007E3.4010009@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

2014-07-11 8:50 GMT-07:00 Tom Lendacky <thomas.lendacky@amd.com>:
> In drivers/net/phy/phy.c there is an array of struct phy_setting named
> settings that is used when auto negotiation is disabled to sanitize
> the phy settings.  This array uses only *baseT* features for validating
> the various speed/duplex combinations.  This may result in not finding
> the correct array entry in regards to speed and duplex if the *baseT*
> feature is not supported.

Part of the reason is that libphy was designed around 2006-2007 and
initially only supported 10/100/1000 PHY devices, and until recently
it did not support 10GbE PHYs at all.

>
> For example, a 10GbE phy that supports KR mode would end up not matching
> an entry and defaulting to the last entry of the array (SPEED_10 and
> DUPLEX_HALF) which is not what is desired.
>
> Is it appropriate to be able to extend this array?  Either by adding
> additional array entries or extending the "setting" to include other
> features?  Or is there a specific reason that only the *baseT* values
> are used?

It seems to me like it will be easier to refine/extend the matching
logic by adding a new entries which contain a single 'setting' to be
matched against, such as the one you show below:

>
> Examples of changing the array:
>
>   Add a new entry
>         {
>                 .speed = SPEED_10000,
>                 .duplex = DUPLEX_FULL,
>                 .setting = SUPPORTED_10000baseKR_Full,
>         },
>
>   or extend current entry
>         {
>                 .speed = SPEED_10000,
>                 .duplex = DUPLEX_FULL,
>                 .setting = SUPPORTED_10000baseT_Full |
>                            SUPPORTED_10000baseKR_Full,
>         },
>
> Thanks,
> Tom



-- 
Florian
