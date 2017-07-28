From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Fri, 28 Jul 2017 06:57:24 +0200
Message-ID: <20170728045724.GA27903@airbook.vandijck-laurijssen.be>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com>
 <20170726164124.GL12049@lunn.ch>
 <355b90b3-97ce-1057-6617-d5d709449c48@hartkopp.net>
 <a77fe395-33c7-9405-b51a-5d3372e5c58b@ti.com>
 <fe99189e-d077-ba65-4dfc-a4d8beee62b3@hartkopp.net>
 <932602fe-d06a-7a17-5a0c-24265cf2e643@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
        robh+dt@kernel.org, quentin.schulz@free-electrons.com,
        sergei.shtylyov@cogentembedded.com
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <932602fe-d06a-7a17-5a0c-24265cf2e643@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> On 07/27/2017 01:47 PM, Oliver Hartkopp wrote:
> > On 07/26/2017 08:29 PM, Franklin S Cooper Jr wrote:
> >>
> > 
> >> I'm fine with switching to using bitrate instead of speed. Kurk was
> >> originally the one that suggested to use the term arbitration and data
> >> since thats how the spec refers to it. Which I do agree with. But your
> >> right that in the drivers (struct can_priv) we just use bittiming and
> >> data_bittiming (CAN-FD timings). I don't think adding "fd" into the
> >> property name makes sense unless we are calling it something like
> >> "max-canfd-bitrate" which I would agree is the easiest to understand.
> >>
> >> So what is the preference if we end up sticking with two properties?
> >> Option 1 or 2?
> >>
> >> 1)
> >> max-bitrate
> >> max-data-bitrate
> >>
> >> 2)
> >> max-bitrate
> >> max-canfd-bitrate
> >>
> >>
> > 
> > 1
> > 
> >>> A CAN transceiver is limited in bandwidth. But you only have one RX and
> >>> one TX line between the CAN controller and the CAN transceiver. The
> >>> transceiver does not know about CAN FD - it has just a physical(!) layer
> >>> with a limited bandwidth. This is ONE limitation.
> >>>
> >>> So I tend to specify only ONE 'max-bitrate' property for the
> >>> fixed-transceiver binding.
> >>>
> >>> The fact whether the CAN controller is CAN FD capable or not is provided
> >>> by the netlink configuration interface for CAN controllers.
> >>
> >> Part of the reasoning to have two properties is to indicate that you
> >> don't support CAN FD while limiting the "arbitration" bit rate.
> > 
> > ??
> > 
> > It's a physical layer device which only has a bandwidth limitation.
> > The transceiver does not know about CAN FD.
> > 
> >> With one
> >> property you can not determine this and end up having to make some
> >> assumptions that can quickly end up biting people.
> > 
> > Despite the fact that the transceiver does not know anything about ISO
> > layer 2 (CAN/CAN FD) the properties should look like
> > 
> >     max-bitrate
> >     canfd-capable
> > 
> > then.
> > 
> > But when the tranceiver is 'canfd-capable' agnostic, why provide a
> > property for it?
> > 
> > Maybe I'm wrong but I still can't follow your argumentation ideas.
> 

The transceiver does not know about CAN FD, but CAN FD uses
the different restrictions of the arbitration & data phase in the CAN
frame, i.e. during arbitration, the RX must indicate the wire
(dominant/recessive) within 1 bit time, during data in CAN FD, this is
not necessary.

So while _a_ transceiver may be spec'd to 1MBit during arbitration,
CAN FD packets may IMHO exceed that speed during data phase.
That was the whole point of CAN FD: exceed the limits required for
correct arbitration on transceiver & wire.

So I do not agree on the single bandwidth limitation.

The word 'max-arbitration-bitrate' makes the difference very clear.

> Your right. I spoke to our CAN transceiver team and I finally get your
> points.
> 
> So yes using "max-bitrate" alone is all we need. Sorry for the confusion
> and I'll create a new rev using this approach.
> > 
> > Regards,
> > Oliver

Kind regards,
Kurt
