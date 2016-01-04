From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/4] net: phy: at803x: Allow specifying the RGMII RX clock
 delay via phy mode
Date: Mon, 04 Jan 2016 14:05:35 -0800
Message-ID: <568AECAF.9040903@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com> <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com> <567F5AD5.40004@gmail.com> <56804898.1030902@free.fr> <CAFBinCC7yOvw=e7tn=TNcJj4tSwuKpaT5KrtGBF1_CoxaDwknQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mans Rullgard <mans@mansr.com>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33830 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbcADWGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:06:07 -0500
Received: by mail-pa0-f41.google.com with SMTP id uo6so183738076pac.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:06:07 -0800 (PST)
In-Reply-To: <CAFBinCC7yOvw=e7tn=TNcJj4tSwuKpaT5KrtGBF1_CoxaDwknQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 13:17, Martin Blumenstingl wrote:
> On Sun, Dec 27, 2015 at 9:22 PM, Mason <slash.tmp@free.fr> wrote:
>> On 27/12/2015 04:28, Florian Fainelli wrote:
>>
>>> Le 25/12/2015 16:27, Martin Blumenstingl wrote:
>>>
>>>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>>>> index f566b6e..0b262a2 100644
>>>> --- a/drivers/net/phy/at803x.c
>>>> +++ b/drivers/net/phy/at803x.c
>>>> @@ -36,8 +36,10 @@
>>>>  #define AT803X_INSR                         0x0013
>>>>  #define AT803X_DEBUG_ADDR                   0x1D
>>>>  #define AT803X_DEBUG_DATA                   0x1E
>>>> -#define AT803X_DEBUG_SYSTEM_MODE_CTRL               0x05
>>>> -#define AT803X_DEBUG_RGMII_TX_CLK_DLY               BIT(8)
>>>> +#define AT803X_DEBUG_REG_0                  0x00
>>>
>>> Seems like the previous register name might have been clearer that the
>>> new name you suggest here, did that come from a different GPL tarball or
>>> documentation?
>>
>> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>>
>> According to the 8035 data sheet, the debug register at offset 0
>> is just "Debug register 0". In fact, the only non-reserved bit is
>> "rgmii rx clock delay enable/disable"
> Thanks for verifying this.
> 
> @Florian: Did you already have time to look at my comments? I know
> it's vacation season, but I'd like to fix all remaining issues soon.

That answers my question, there were still two other things that needed
to be addressed:

- the bool parameter to the enable RX/TX delay is currently only set to
"true"
- the mutex does not need to be acquired

Could you respin this patch series with this addressed? Thanks!
-- 
Florian
