From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH 5/7] net:mdio-mux: Add MDIO mux driver for iProc SoCs
Date: Mon, 30 May 2016 20:09:08 +0530
Message-ID: <c26a73e6243f0cf11b7745ac5bcc8a4b@mail.gmail.com>
References: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
 <1464592251-2688-6-git-send-email-pramod.kumar@broadcom.com> <20160530133442.GK6027@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160530133442.GK6027@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thanks for reviewing. Please see my comment inline.

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: 30 May 2016 19:05
> To: Pramod Kumar
> Cc: Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell; Kumar Gala;
Catalin
> Marinas; Will Deacon; Kishon Vijay Abraham I; David S. Miller;
> devicetree@vger.kernel.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com;
linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH 5/7] net:mdio-mux: Add MDIO mux driver for iProc
SoCs
>
> On Mon, May 30, 2016 at 12:40:49PM +0530, Pramod Kumar wrote:
> > iProc based SoCs supports the integrated mdio multiplexer which has
> > the bus selection as well as mdio transaction generation logic inside.
>
> Hi Pramod
>
> Great to see you using the existing MDIO framework. Thanks.
>
> > +static int mdio_mux_iproc_switch_fn(int current_child, int
desired_child,
> > +				    void *data)
> > +{
> > +	struct iproc_mdiomux_desc *md = data;
> > +	struct mdiomux_bus_param *bp = &md->bus_param[desired_child];
> > +	u32 param, bus_id;
> > +	bool bus_dir;
> > +
> > +	/* select bus and its properties */
> > +	bus_dir = (desired_child < EXT_BUS_START_ADDR);
> > +	bus_id = bus_dir ? desired_child : (desired_child -
> > +EXT_BUS_START_ADDR);
> > +
> > +	param = (bus_dir ? 1 : 0) << MDIO_PARAM_INTERNAL_SEL;
> > +	param |= (bp->is_c45 ? 1 : 0) << MDIO_PARAM_C45_SEL;
> > +	param |= (bus_id << MDIO_PARAM_BUS_ID);
> > +
> > +	writel(param, md->base + MDIO_PARAM_OFFSET);
> > +	return 0;
> > +}
>
> What i don't yet see is why you went for the concept of an integrated
MDIO and
> MUX. This function above is the mux function, and it looks like it could
be used
> to implement a standard mdio-mux driver.
>

iProc based SoCs Integrated MDIO Multiplexer has both logic in a hardware.
MDIO transaction and Child bus selection logic share the same address
space.
For ex-

In above mux function- Register-MDIO_PARAM_OFFSET is used for bus,
direction and transaction type. Same register
Is used for programming the PHY Ids and write data values in MDIO parent
bus transaction.

Writing MDIO bus driver and mux driver separately gives a notion of being
two separate device/address space, obviously it is not our use case.
Even if we used syscon for accessing the shared register, this does not
appears good for writing separate drivers for a single device.


> Thanks
>      Andrew

Regards,
Pramod
