From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 2/5] net: phy: sun8i-h3-ephy: Add driver for Allwinner
 H3 Ethernet PHY
Date: Mon, 11 Apr 2016 12:23:18 -0700
Message-ID: <570BF9A6.2040109@gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-3-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459786954-12649-3-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/04/16 09:22, Chen-Yu Tsai wrote:
> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
> configured through a memory mapped hardware register.
> 
> This same register also configures the MAC interface mode and TX clock
> source. Also covered by the register, but not supported in this driver,
> are TX/RX clock delay chains and inverters, and an RMII module.

This is not really a PHY driver, more a driver for a special piece of
hardware responsible for properly configuring a more standard integrated
PHY which is then driven via standard MDIO accesses, right?

The intention to make this driver re-usable is fine, but still makes me
wonder if it should not be put in a file which is linked into the
Ethernet MAC driver, and utilized by this one in a way that may be more
"ad-hoc" than what you are proposing here.

One thing that is not obvious here, is how is the device parenting done?
Are we able to associate a phy_device to this SUN8I_H3_EPHY platform
device here?

Another thing is that the Ethernet MAC driver is fully aware of when
putting an Ethernet PHY into suspend, shutdown, or fully functional
power state should occur, if you have a separate platform driver here
which does not listen for such kinds of events (hint: none are generated
right now), then you cannot implement a working power state interface
between the MAC, SHIM and PHY here, even though you would want that.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
