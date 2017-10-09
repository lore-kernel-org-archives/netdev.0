From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] ravb: Add optional PHY reset during system resume
Date: Mon, 9 Oct 2017 12:37:36 +0300
Message-ID: <316a7f99-d2ca-cdb2-2eca-deb044085c52@cogentembedded.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-3-git-send-email-geert+renesas@glider.be>
 <406f7aff-e386-31f3-39d3-17523443c265@gmail.com>
 <CAMuHMdWOAnT3xONPfU8pJi9fbAgtWL2GyRbooAxrfGDb=bsB_A@mail.gmail.com>
 <1a474c45-29ea-82fa-1ab0-0febfdc38bcb@gmail.com>
 <47456e34-2c2f-ec19-fcda-e3132a8037b3@cogentembedded.com>
 <846bb632-9fcf-3306-c2cf-4d913fd1834a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:47174 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdJIJhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:37:39 -0400
Received: by mail-lf0-f45.google.com with SMTP id k40so7110508lfi.4
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 02:37:39 -0700 (PDT)
In-Reply-To: <846bb632-9fcf-3306-c2cf-4d913fd1834a@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/1/2017 7:34 PM, Florian Fainelli wrote:

>>>>>> If the optional "reset-gpios" property is specified in DT, the generic
>>>>>> MDIO bus code takes care of resetting the PHY during device probe.
>>>>>> However, the PHY may still have to be reset explicitly after system
>>>>>> resume.
>>>>>>
>>>>>> This allows to restore Ethernet operation after resume from s2ram on
>>>>>> Salvator-XS, where the enable pin of the regulator providing PHY power
>>>>>> is connected to PRESETn, and PSCI suspend powers down the SoC.
>>>>>>
>>>>>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>>>>>> ---
>>>>>>    drivers/net/ethernet/renesas/ravb_main.c | 9 +++++++++
>>>>>>    1 file changed, 9 insertions(+)
>>>>>>
>>>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> index fdf30bfa403bf416..96d1d48e302f8c9a 100644
>>>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>> [...]
>>>>>> @@ -2302,6 +2304,13 @@ static int __maybe_unused ravb_resume(struct
>>>>>> device *dev)he patches
>>>>>>          * reopen device if it was running before system suspended.
>>>>>>          */
>>>>>>
>>>>>> +     /* PHY reset */
>>>>>> +     if (bus->reset_gpiod) {
>>>>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 1);
>>>>>> +             udelay(bus->reset_delay_us);
>>>>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 0);
>>>>>> +     }
>>>>>
>>>>> This is a clever hack, but unfortunately this is also misusing the MDIO
>>>>> bus reset line into a PHY reset line. As commented in patch 3, if this
>>>>> reset line is tied to the PHY, then this should be a PHY property and
>>>>
>>>> OK.
>>>>
>>>>> you cannot (ab)use the MDIO bus GPIO reset logic anymore...
>>>>
>>>> And then I should add reset-gpios support to drivers/net/phy/micrel.c?
>>>> Or is there already generic code to handle per-PHY reset? I couldn't
>>>> find it.
>>>
>>> There is not such a thing unfortunately, but it would presumably be
>>
>>     It's strange you don't remember about my (abandoned) patches to
>> handle per=PHY reset GPIOs -- perhaps it's time to unearth them. Here
>> they are:
>>
>> http://patchwork.ozlabs.org/patch/616495/
>> http://patchwork.ozlabs.org/patch/616501/
>>
>>     I had v3 in the works before abandoning this series -- it doesn't
>> apply now.
> 
> Should Geert pick-up where you left and address the feedback given in
> v2, or do you plan to post a rebased v3?

    I was going to address the rejects in v3 and give the patchset to Geert... 
unfortunately, this took so-o-o long. I'm going to do it today, at last.

[...]

MBR, Sergei
