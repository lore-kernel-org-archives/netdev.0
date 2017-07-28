From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Fri, 28 Jul 2017 15:02:31 +0200
Message-ID: <20170728130231.GA10680@airbook.vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Franklin S Cooper Jr <fcooper@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
        robh+dt@kernel.org, quentin.schulz@free-electrons.com,
        sergei.shtylyov@cogentembedded.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> On 07/28/2017 06:57 AM, Kurt Van Dijck wrote:
> 
> >So while _a_ transceiver may be spec'd to 1MBit during arbitration,
> >CAN FD packets may IMHO exceed that speed during data phase.
> 
> When the bitrate is limited to 1Mbit/s you are ONLY allowed to use 1Mbit/s
> in the data section too (either with CAN or CAN FD).

My point is that the requirements posed to a transceiver
differ between arbitration & data phase for CAN FD.
So while a transceiver does not know about CAN FD, it may allow
higher bitrates for the data phase.

> 
> >That was the whole point of CAN FD: exceed the limits required for
> >correct arbitration on transceiver & wire.
> 
> No. CAN FD is about a different frame format with up to 64 bytes AND the
> possibility to increase the bitrate in the data section of the frame.
> 
> >So I do not agree on the single bandwidth limitation.
> 
> The transceiver provides a single maximum bandwidth. It's an ISO Layer 1
> device.
> 
> >The word 'max-arbitration-bitrate' makes the difference very clear.
> 
> I think you are mixing up ISO layer 1 and ISO layer 2.

In order to provide higher data throughput without putting extra limits
on transceiver & wire, the requirement for the round-trip delay to be
within 1 bittime has been eliminated, but only for the data phase when
arbitration is over.
So layer 2 (CAN FD) has been adapted to circumvent the layer 1
(transceiver + wire) limitations.

In fact, the round-trip delay requirement never actually did matter for
plain CAN during data bits either. CAN FD just makes use of that,
but is therefore incompatible on the wire.

I forgot the precise wording, but this is the principle that Bosch
explained on the CAN conference in Nurnberg several years ago, or at
least this is how I remembered it :-)

I haven't followed the developments of transceivers, but with the above
principle in mind, it's obvious that any transceiver allows higher
bitrates during the data segment because the TX-to-RX line delay must
not scale with the bitrate.
In reality, maybe not all transceivers will mention this in their
datasheet.

So whether you call it 'max-arbitration-bitrate' & 'max-data-bitrate'
or 'max-bitrate' & 'max-data-bitrate' does not really matter (I prefer
1st) but you will one day need 2 bitrates.

Kind regards,
Kurt
