From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: Re: CAN-FD Transceiver Limitations
Date: Fri, 30 Jun 2017 12:51:31 -0500
Message-ID: <7883a83f-6af7-3ac8-a5ab-449ca1ab889a@ti.com>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch> <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
 <20170629154139.GC13221@lunn.ch>
 <c0d3d772-6939-d22c-b954-3ba6486a9ede@ti.com>
 <20170629223551.GA6568@airbook.vandijck-laurijssen.be>
 <d5c2e2f2-8b74-58e1-0cc8-727ba39bd14c@ti.com>
 <20170630080906.GA26712@airbook.vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170630080906.GA26712-W3bwb+3xS1LIj2mJfgo99rBP9FGTfoIhIWnq8iejnXE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kurt,

On 06/30/2017 03:09 AM, Kurt Van Dijck wrote:
>> On 06/29/2017 05:36 PM, Kurt Van Dijck wrote:
>>>>>>
>>>>>> mcan@0 {
>>>>>> 	...
>>>>>> 	fixed-transceiver {
>>>>>> 	      max-canfd-speed = <2000>
>>>>>> 	};
>>>>>> 	...
>>>>>> };
>>>
>>> Since when would a transceiver support different speeds for CAN & CANFD?
>>
>> When I say CAN I'm referring to CAN 2.0 specification which mentioned
>> speeds upto 1 Mbit/s. While CAN FD supports higher bitrates.
> 
> linux-can is not necessarily restricted to CAN 2.0B?
> 
>>
>>> No transceivers were available, but they are now.
>>> I see no datalink problem applying 2MBit for regular CAN with apropriate
>>> physical layer, and CAN does not predefine the physical layer
>>> (advise != define).
>>>
>>> IMHO,
>>> 	fixed-transceiver {
>>> 		max-arbitration-speed = <2000000>
>>> 		max-data-speed = <4000000>
>>> 	};
>>> is way better to describe the hardware.
>>> Regular CAN chips would not consider max-data-speed...
>>
>> What is arbitration speed?
> 
> CANFD remains similar during the arbitration phase (when the CAN id is
> sent on the wire), and after that allows to switch to a higher 'data'
> speed because the round-trip wire restrictions during arbitration
> don't apply anymore.
> 
>>
>> Also if I understand you correctly then I agree drivers for traditional
>> CAN wouldn't care about this subnode. Although it may be helpful for
>> max-data-speed to become max-canfd-speed or something along those lines.
>> Just so the property's purpose is clear.
> 
> Transceivers exist that don't support 1MB either.
> naming the speeds max-arbitration-speed and max-data-speed makes this
> OF nodes usable for that kind of CAN 2.0 restrtications too.
> 
> Of course, CAN 2.0 chips only consider max-arbitration-speed as that
> applies to the whole wire bitstream, where as CANFD considers both.
> 
> What I understand of your proposal is that max-arbitration-speed is
> 'fixed to 1MB anyway', and that assumption has been proven not
> universally applicable with CAN2.0 transceivers already.
> 
> I found the name 'max-canfd-speed' a bit dubious as CANFD relies on
> 'flexible datarate'. transceivers may not necessarily support the same
> speed for both arbitration and data.
> So I propose to replace it with 'max-data-speed'

Thanks for the explanation. Makes sense.
> 
> Kind regards,
> Kurt
> 
>>>
>>> Kind regards,
>>> Kurt
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-can" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
