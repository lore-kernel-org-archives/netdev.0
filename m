From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 27 Jan 2015 10:53:53 +0000
Message-ID: <20150127105353.GC17721@leverpostej>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
 <20150123105114.GB23493@leverpostej>
 <54C613F2.5090507@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stathis Voukelatos <stathisv70@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54C613F2.5090507@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2015 at 10:16:18AM +0000, Stathis Voukelatos wrote:
> 
> On 23/01/15 10:51, Mark Rutland wrote:
> >
> > diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> > new file mode 100644
> > index 0000000..6b6e105
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> > @@ -0,0 +1,27 @@
> > +* Linn Products Ethernet Packet Sniffer
> > +
> > +Required properties:
> > +- compatible : must be "linn,eth-sniffer"
> > +- reg : physical addresses and sizes of registers. Must contain 3 entries:
> > +          first entry: registers memory space
> > +          second entry: TX command memory
> > +          third entry: RX command memory
> > Just to check: are those memories are part of the packet sniffer device,
> > or are carveouts from other memory?
> Yes, the 3 memory areas are part of the packet sniffer module.
> >> +- fifo-block-words : number of words in one data FIFO entry
> >> +
> >> +Example:
> >> +
> >> +sniffer@1814a000 {
> >> +        compatible = "linn,eth-sniffer";
> >> +        reg = <0x1814a000 0x100>, <0x1814a400 0x400>, <0x1814a800 0x400>;
> >> +        reg-names = "regs", "tx-ram", "rx-ram";
> >> +        interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
> >> +        interrupt-names = "eth-sniffer-irq";
> >> +        clocks = <&system_clk>;
> >> +        clock-names = "sys";
> >> +        fifo-block-words = <4>;
> >> +    };
> > Surely the relationship between the sniffer, MAC, and PHY should be
> > described, so we know which interface the sniffer is related to?
> >
> The packet sniffer sits between the MAC and the PHY and monitors TX or RX
> packets, or both. Will add a description in the binding doc.

I understood that. However the binding does not explicitly refer to
either of those, so I don't see how you'd associate this sniffer
instance with the relevant PHY+MAC instances.

That should be made explicit in the binding.

Mark.
