From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Thu, 27 Jul 2017 20:47:37 +0200
Message-ID: <fe99189e-d077-ba65-4dfc-a4d8beee62b3@hartkopp.net>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com> <20170726164124.GL12049@lunn.ch>
 <355b90b3-97ce-1057-6617-d5d709449c48@hartkopp.net>
 <a77fe395-33c7-9405-b51a-5d3372e5c58b@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org,
        sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org
To: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a77fe395-33c7-9405-b51a-5d3372e5c58b-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/26/2017 08:29 PM, Franklin S Cooper Jr wrote:
>

> I'm fine with switching to using bitrate instead of speed. Kurk was
> originally the one that suggested to use the term arbitration and data
> since thats how the spec refers to it. Which I do agree with. But your
> right that in the drivers (struct can_priv) we just use bittiming and
> data_bittiming (CAN-FD timings). I don't think adding "fd" into the
> property name makes sense unless we are calling it something like
> "max-canfd-bitrate" which I would agree is the easiest to understand.
>
> So what is the preference if we end up sticking with two properties?
> Option 1 or 2?
>
> 1)
> max-bitrate
> max-data-bitrate
>
> 2)
> max-bitrate
> max-canfd-bitrate
>
>

1

>> A CAN transceiver is limited in bandwidth. But you only have one RX and
>> one TX line between the CAN controller and the CAN transceiver. The
>> transceiver does not know about CAN FD - it has just a physical(!) layer
>> with a limited bandwidth. This is ONE limitation.
>>
>> So I tend to specify only ONE 'max-bitrate' property for the
>> fixed-transceiver binding.
>>
>> The fact whether the CAN controller is CAN FD capable or not is provided
>> by the netlink configuration interface for CAN controllers.
>
> Part of the reasoning to have two properties is to indicate that you
> don't support CAN FD while limiting the "arbitration" bit rate.

??

It's a physical layer device which only has a bandwidth limitation.
The transceiver does not know about CAN FD.

> With one
> property you can not determine this and end up having to make some
> assumptions that can quickly end up biting people.

Despite the fact that the transceiver does not know anything about ISO 
layer 2 (CAN/CAN FD) the properties should look like

	max-bitrate
	canfd-capable

then.

But when the tranceiver is 'canfd-capable' agnostic, why provide a 
property for it?

Maybe I'm wrong but I still can't follow your argumentation ideas.

Regards,
Oliver
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
