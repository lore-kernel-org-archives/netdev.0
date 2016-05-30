From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 5/7] net:mdio-mux: Add MDIO mux driver for iProc SoCs
Date: Mon, 30 May 2016 15:34:42 +0200
Message-ID: <20160530133442.GK6027@lunn.ch>
References: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
 <1464592251-2688-6-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464592251-2688-6-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 30, 2016 at 12:40:49PM +0530, Pramod Kumar wrote:
> iProc based SoCs supports the integrated mdio multiplexer which
> has the bus selection as well as mdio transaction generation logic
> inside.

Hi Pramod

Great to see you using the existing MDIO framework. Thanks.

> +static int mdio_mux_iproc_switch_fn(int current_child, int desired_child,
> +				    void *data)
> +{
> +	struct iproc_mdiomux_desc *md = data;
> +	struct mdiomux_bus_param *bp = &md->bus_param[desired_child];
> +	u32 param, bus_id;
> +	bool bus_dir;
> +
> +	/* select bus and its properties */
> +	bus_dir = (desired_child < EXT_BUS_START_ADDR);
> +	bus_id = bus_dir ? desired_child : (desired_child - EXT_BUS_START_ADDR);
> +
> +	param = (bus_dir ? 1 : 0) << MDIO_PARAM_INTERNAL_SEL;
> +	param |= (bp->is_c45 ? 1 : 0) << MDIO_PARAM_C45_SEL;
> +	param |= (bus_id << MDIO_PARAM_BUS_ID);
> +
> +	writel(param, md->base + MDIO_PARAM_OFFSET);
> +	return 0;
> +}

What i don't yet see is why you went for the concept of an integrated
MDIO and MUX. This function above is the mux function, and it looks
like it could be used to implement a standard mdio-mux driver.

Thanks
     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
