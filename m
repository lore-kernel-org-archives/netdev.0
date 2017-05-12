From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v5 15/17] dt-bindings: qca7000: append UART interface to
 binding
Date: Thu, 11 May 2017 19:45:41 -0700
Message-ID: <20170511194541.4e58cb7d@cakuba.netronome.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
        <1494406408-31760-16-git-send-email-stefan.wahren@i2se.com>
        <1702237.66ccflAQAJ@kerker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>,
        Stefan Wahren <stefan.wahren@i2se.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Michael Heimpold <mhei@heimpold.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1702237.66ccflAQAJ@kerker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 May 2017 21:12:22 +0200, Michael Heimpold wrote:
> Am Mittwoch, 10. Mai 2017, 10:53:26 CEST schrieb Stefan Wahren:
> > This merges the serdev binding for the QCA7000 UART driver (Ethernet over
> > UART) into the existing document.
> > 
> > Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> > ---
> >  .../devicetree/bindings/net/qca-qca7000.txt        | 32
> > ++++++++++++++++++++++ 1 file changed, 32 insertions(+)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/qca-qca7000.txt
> > b/Documentation/devicetree/bindings/net/qca-qca7000.txt index
> > a37f656..08364c3 100644
> > --- a/Documentation/devicetree/bindings/net/qca-qca7000.txt
> > +++ b/Documentation/devicetree/bindings/net/qca-qca7000.txt
> > @@ -54,3 +54,35 @@ ssp2: spi@80014000 {
> >  		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
> >  	};
> >  };
> > +
> > +(b) Ethernet over UART
> > +
> > +In order to use the QCA7000 as UART slave it must be defined as a child of
> > a +UART master in the device tree. It is possible to preconfigure the UART
> > +settings of the QCA7000 firmware, but it's not possible to change them
> > during +runtime.
> > +
> > +Required properties:
> > +- compatible        : Should be "qca,qca7000-uart"  
> 
> I already discussed this with Stefan off-list a little bit, but I would like
> to bring this to a broader audience: I'm not sure whether the compatible 
> should contain the "-uart" suffix, because the hardware chip is the very same
> QCA7000 chip which can also be used with SPI protocol.
> The only difference is the loaded firmware within the chip which can either
> speak SPI or UART protocol (but not both at the same time - due to shared 
> pins). So the hardware design decides which interface type is used.
> 
> At the moment, this patch series adds a dedicated driver for the UART 
> protocol, in parallel to the existing SPI driver. So a different compatible
> string is needed here to match against the new driver.
> 
> An alternative approach would be to re-use the existing compatible string
> "qca,qca7000" for both, the SPI and UART protocol, because a "smarter" 
> (combined) driver would detect which protocol to use. For example the driver 
> could check for spi-cpha and/or spi-cpol which are required for SPI protocol: 
> if these exists the driver could assume that SPI must be used, if both are 
> missing then UART protocol should be used.
> (This way it would not be necessary to check whether the node is a child of
> a SPI or UART master node - but maybe this is even easier - I don't know)
> 
> Or in shorter words: my concern is that while "qca7000-uart" describes the 
> hardware, it's too closely coupled to the driver implementation. Having
> some feedback of the experts would be nice :-)

I'm no expert, but devices which can do both I2C and SPI are quite
common, and they usually have the same compatible string for both
buses.
