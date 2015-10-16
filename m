From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: phy: smsc: disable energy detect mode
Date: Fri, 16 Oct 2015 09:27:41 -0700
Message-ID: <CAGVrzcZLTg_2tUCTyMkEF7y-Esh5ByZsputO6u41RLPizCcz+Q@mail.gmail.com>
References: <1444713189-23063-1-git-send-email-hs@denx.de> <561D5AC8.7040801@gmail.com>
 <561DD749.9000802@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Georg.Soffel-k21M0aUVSxZWk0Htik3J/w@public.gmane.org
To: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <561DD749.9000802-ynQEQJNshbs@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2015-10-13 21:17 GMT-07:00 Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>:
> Hello Florian,
>
>
> Am 13.10.2015 um 21:26 schrieb Florian Fainelli:
>>
>> On 12/10/15 22:13, Heiko Schocher wrote:
>>>
>>> On some boards the energy enable detect mode leads in
>>> trouble with some switches, so make the enabling of
>>> this mode configurable through DT.
>>>
>>> Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
>>> ---
>>>
>>>   .../devicetree/bindings/net/smsc-lan87xx.txt       | 19
>>> +++++++++++++++++
>>>   drivers/net/phy/smsc.c                             | 24
>>> +++++++++++++++++-----
>>>   2 files changed, 38 insertions(+), 5 deletions(-)
>>>   create mode 100644
>>> Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>>> b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>>> new file mode 100644
>>> index 0000000..39aa1dc
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/smsc-lan87xx.txt
>>> @@ -0,0 +1,19 @@
>>> +SMSC LAN87xx Ethernet PHY
>>> +
>>> +Some boards require special tuning values. Configure them
>>> +through an Ethernet OF device node.
>>> +
>>> +Optional properties:
>>> +
>>> +- disable-energy-detect:
>>> +  If set, do not enable energy detect mode for the SMSC phy.
>>> +  default: enable energy detect mode
>>
>>
>> Although energy detection is something that is implemented by many PHYs,
>> I am not sure a generic property is suitable here, I would prefix that
>> with the SMSC vendor prefix here to make it clear this only applies to
>> this PHY.
>
>
> Hmm... but all PHYs should be able to enable, disable it in some way, or?

It may not always be controlled directly at the PHY level, sometimes
this is something that needs cooperation with the Ethernet MAC as well
in case of integrated designs.

>
>> Would not you want to make it a reverse property here though, something
>> like this:
>>
>> smsc,energy-detect: boolean, when present indicates the PHY reliably
>> supports energy detection
>
>
> Yes, that was also my first thought, but currently, on this PHYs
> energy detect mode is on ... and if I introduce such a property,
> it will disable it for all existing boards, because property is
> missing ... so, maybe I break boards ...

Fair enough, how about smsc,disabled-energy-detect or something like that then?
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
