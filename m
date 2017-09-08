From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 13:58:34 -0700
Message-ID: <01ed87f4-09bc-21f0-7d41-a4b245cfa4bd@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <8e4aa981-7f41-047d-2101-370118b4f2c0@gmail.com>
 <CAJGZr0Kp5ZKmFJT+KX9jxMVyZT9=VO0_dpZqE+y1TNaYvURcoQ@mail.gmail.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121EF7@CHN-SV-EXMX02.mchp-main.com>
 <508d7ef0-e351-5369-b477-b027bae3dda4@gmail.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121F35@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com,
        muvarov@gmail.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121F35@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/08/2017 01:07 PM, Tristram.Ha@microchip.com wrote:
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Friday, September 08, 2017 12:54 PM
>> To: Tristram Ha - C24268; muvarov@gmail.com
>> Cc: andrew@lunn.ch; pavel@ucw.cz; nathan.leigh.conrad@gmail.com;
>> vivien.didelot@savoirfairelinux.com; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; Woojung Huh - C21699
>> Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
>> drivers can be added
>>
>> On 09/08/2017 12:48 PM, Tristram.Ha@microchip.com wrote:
>>>> -----Original Message-----
>>>> From: Maxim Uvarov [mailto:muvarov@gmail.com]
>>>> Sent: Friday, September 08, 2017 12:00 PM
>>>> To: Florian Fainelli
>>>> Cc: Tristram Ha - C24268; Andrew Lunn; Pavel Machek; Nathan Conrad; Vivien
>>>> Didelot; netdev; linux-kernel@vger.kernel.org; Woojung Huh - C21699
>>>> Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that
>> new
>>>> drivers can be added
>>>>
>>>> 2017-09-08 21:48 GMT+03:00 Florian Fainelli <f.fainelli@gmail.com>:
>>>>> On 09/07/2017 02:11 PM, Tristram.Ha@microchip.com wrote:
>>>>>> From: Tristram Ha <Tristram.Ha@microchip.com>
>>>>>>
>>>>>> Add other KSZ switches support so that patch check does not complain.
>>>>>>
>>>>>> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
>>>>>> ---
>>>>>>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 117
>>>>>> ++++++++++++----------
>>>>>>  1 file changed, 62 insertions(+), 55 deletions(-)
>>>>>>
>>>>>> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt
>>>>>> b/Documentation/devicetree/bindings/net/dsa/ksz.txt
>>>>>> index 0ab8b39..34af0e0 100644
>>>>>> --- a/Documentation/devicetree/bindings/net/dsa/ksz.txt
>>>>>> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
>>>>>> @@ -3,8 +3,15 @@ Microchip KSZ Series Ethernet switches
>>>>>>
>>>>>>  Required properties:
>>>>>>
>>>>>> -- compatible: For external switch chips, compatible string must be
>>>>>> exactly one
>>>>>> -  of: "microchip,ksz9477"
>>>>>> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
>>>>>> +           "microchip,ksz8795" for KSZ8795 chip,
>>>>>> +           "microchip,ksz8794" for KSZ8794 chip,
>>>>>> +           "microchip,ksz8765" for KSZ8765 chip,
>>>>>> +           "microchip,ksz8895" for KSZ8895 chip,
>>>>>> +           "microchip,ksz8864" for KSZ8864 chip,
>>>>>> +           "microchip,ksz8873" for KSZ8873 chip,
>>>>>> +           "microchip,ksz8863" for KSZ8863 chip,
>>>>>> +           "microchip,ksz8463" for KSZ8463 chip
>>>>>
>>>>
>>>>
>>>> Tristram, does any of this devices support chaining?
>>>>
>>>> Maxim.
>>>
>>> They do not if you mean daisy-chaining the switches together.
>>
>> Marvell tags allow you to specify both a port and switch index
>> destination after setting up an appropriate routing table, I am assuming
>> this is not supported.
>>
>> What happens though if I connect two KSZ switches ones to another say:
>>
>> eth0
>> 	-> KSZ8463
>> 		-> KSZ8463
>>
>> Will the first switch terminates KSZ tag if it sees two tags
>> encapsulated in another, something like this:
>>
>> | MAC DA | MAC SA | .... payload | Inner KSZ tag | Inner KSZ tag | FCS |
>>
> 
> In theory it is doable by adding more tags and remember which port
> is connected to the cpu port of another switch, but there is no switch
> forwarding and everything is handled by software.

Fair enough.

> 
>>>
>>> There is always a problem that once tail tagging mode is enabled
>>> sending a frame through the MAC without going through the DSA
>>> layer will cause the frame to be dropped.
>>
>> Yes, once the master network device is used for DSA, it is still usable
>> directly by e.g: applications, but it won't do anything if the switch is
>> configured such that it drops ingressing frames not having the proper
>> tag. We documented that here:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Docume
>> ntation/networking/dsa/dsa.txt#n275
>> --
> 
> As the DSA was developed for the Marvell switches I assumed they can
> forward frame without a tag.

Once you use tags with your switch, eth0/master netdev/conduit interface
no longer has a purpose as a normal interface because we create per-port
network devices. That means if you want to send packets towards Port 0
you use the proper network interface. If you create a bridge, you will
use brX as the network device to send/receive packets from, in all
cases, the packets originate from the CPU and the frame ingresses the
switch with the proper information within the tag to target the vector
of ports.

If you have tags enabled and you use eth0 to send packets towards the
switch, there are not that many options, either you have the proper tag,
and the switch will forward to the right port which can be the CPU port
itself if you want, but why do that?

When tags are not enabled (e.g: b53) that is slightly different,
eth0/master/conduit remains usable as a normal interface would, but
unless you start adding VLAN tags, you cannot quite differentiate where
the traffic from LAN to CPU is coming from, so this has limited usefulness.

Hope this clears things.
-- 
Florian
