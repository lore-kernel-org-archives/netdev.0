From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: stmmac: Add OXNAS Glue Driver
Date: Mon, 31 Oct 2016 11:20:36 +0100
Message-ID: <CAGhQ9Vxy+boEPV3pvRCAWAWh-Tie31oS0PG7F6ix5_Wf=JHxgg@mail.gmail.com>
References: <20161021084445.24989-1-narmstrong@baylibre.com>
 <20161030204110.otvjlanmi7dv7fox@rob-hp-laptop> <04b8ed79-8efa-cc10-a9a3-fdee10e0723c@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "peppe.cavallaro" <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-oxnas-Xt5XgHjqiBU06sgRBLv0+0B+6BGkLq7r@public.gmane.org,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <04b8ed79-8efa-cc10-a9a3-fdee10e0723c-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Neil,

On 31 October 2016 at 10:55, Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> wrote:
> On 10/30/2016 09:41 PM, Rob Herring wrote:
>> On Fri, Oct 21, 2016 at 10:44:45AM +0200, Neil Armstrong wrote:
>>> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>>>
>>> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>>> ---
>>>  .../devicetree/bindings/net/oxnas-dwmac.txt        |  44 +++++
>>
>> It's preferred that bindings are a separate patch.
>
> OK
>
>>
>>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
>>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 219 +++++++++++++++++++++
>>>  4 files changed, 275 insertions(+)
>>>  create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
>>>
>>> Changes since RFC at https://patchwork.kernel.org/patch/9387257 :
>>>  - Drop init/exit callbacks
>>>  - Implement proper remove and PM callback
>>>  - Call init from probe
>>>  - Disable/Unprepare clock if stmmac probe fails
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/oxnas-dwmac.txt b/Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>> new file mode 100644
>>> index 0000000..5d2696c
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>> @@ -0,0 +1,44 @@
>>> +* Oxford Semiconductor OXNAS DWMAC Ethernet controller
>>> +
>>> +The device inherits all the properties of the dwmac/stmmac devices
>>> +described in the file stmmac.txt in the current directory with the
>>> +following changes.
>>> +
>>> +Required properties on all platforms:
>>> +
>>> +- compatible:       Depending on the platform this should be one of:
>>> +                    - "oxsemi,ox820-dwmac"
>>> +            Additionally "snps,dwmac" and any applicable more
>>> +            detailed version number described in net/stmmac.txt
>>> +            should be used.
>>
>> You should be explicit what version applies to ox820. "snps,dwmac"
>> should probably be deprecated IMO. There are so many variations of DW
>> h/w.
>
> Well, to be honest I have absolutely no idea ! But I will try to find out...

You can see in the boot log:

>From lpc18xx boot:
[    3.242253] stmmac - user ID: 0x11, Synopsys ID: 0x36
[    3.247653]  Ring mode enabled
[    3.251491]  DMA HW capability register supported
[    3.256336]  Enhanced/Alternate descriptors
[    3.261537]  Enabled extended descriptors
[    3.265968]  RX Checksum Offload Engine supported (type 2)
[    3.272249]  TX Checksum insertion supported
[    3.276874]  Wake-Up On Lan supported
[    3.283743]  Enable RX Mitigation via HW Watchdog Timer
[    3.326701] libphy: stmmac: probed

Synopsys ID: 0x36 and user UD: 0x11, gives us DWMAC version 3.611


regards,
Joachim Eastwood
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
