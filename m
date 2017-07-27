From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Thu, 27 Jul 2017 16:10:14 -0500
Message-ID: <932602fe-d06a-7a17-5a0c-24265cf2e643@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com> <20170726164124.GL12049@lunn.ch>
 <355b90b3-97ce-1057-6617-d5d709449c48@hartkopp.net>
 <a77fe395-33c7-9405-b51a-5d3372e5c58b@ti.com>
 <fe99189e-d077-ba65-4dfc-a4d8beee62b3@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>,
        <sergei.shtylyov@cogentembedded.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <fe99189e-d077-ba65-4dfc-a4d8beee62b3@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/27/2017 01:47 PM, Oliver Hartkopp wrote:
> On 07/26/2017 08:29 PM, Franklin S Cooper Jr wrote:
>>
> 
>> I'm fine with switching to using bitrate instead of speed. Kurk was
>> originally the one that suggested to use the term arbitration and data
>> since thats how the spec refers to it. Which I do agree with. But your
>> right that in the drivers (struct can_priv) we just use bittiming and
>> data_bittiming (CAN-FD timings). I don't think adding "fd" into the
>> property name makes sense unless we are calling it something like
>> "max-canfd-bitrate" which I would agree is the easiest to understand.
>>
>> So what is the preference if we end up sticking with two properties?
>> Option 1 or 2?
>>
>> 1)
>> max-bitrate
>> max-data-bitrate
>>
>> 2)
>> max-bitrate
>> max-canfd-bitrate
>>
>>
> 
> 1
> 
>>> A CAN transceiver is limited in bandwidth. But you only have one RX and
>>> one TX line between the CAN controller and the CAN transceiver. The
>>> transceiver does not know about CAN FD - it has just a physical(!) layer
>>> with a limited bandwidth. This is ONE limitation.
>>>
>>> So I tend to specify only ONE 'max-bitrate' property for the
>>> fixed-transceiver binding.
>>>
>>> The fact whether the CAN controller is CAN FD capable or not is provided
>>> by the netlink configuration interface for CAN controllers.
>>
>> Part of the reasoning to have two properties is to indicate that you
>> don't support CAN FD while limiting the "arbitration" bit rate.
> 
> ??
> 
> It's a physical layer device which only has a bandwidth limitation.
> The transceiver does not know about CAN FD.
> 
>> With one
>> property you can not determine this and end up having to make some
>> assumptions that can quickly end up biting people.
> 
> Despite the fact that the transceiver does not know anything about ISO
> layer 2 (CAN/CAN FD) the properties should look like
> 
>     max-bitrate
>     canfd-capable
> 
> then.
> 
> But when the tranceiver is 'canfd-capable' agnostic, why provide a
> property for it?
> 
> Maybe I'm wrong but I still can't follow your argumentation ideas.

Your right. I spoke to our CAN transceiver team and I finally get your
points.

So yes using "max-bitrate" alone is all we need. Sorry for the confusion
and I'll create a new rev using this approach.
> 
> Regards,
> Oliver
