From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH V2] net/dt: Add support for overriding phy configuration from device tree
Date: Thu, 16 Jan 2014 16:16:46 +0100
Message-ID: <7510122.cayuQ6qt8r@wuerfel>
References: <20140116135905.GV20094@book.gsilab.sittig.org> <1389883631-1480-1-git-send-email-matthew.garrett@nebula.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org
To: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389883631-1480-1-git-send-email-matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 16 January 2014 09:47:11 Matthew Garrett wrote:
> +               if (!of_property_read_u32(np, "phy-mii-advertise-10half",
> +                                          &tmp)) {
> +                       if (tmp) {
> +                               *val |= ADVERTISE_10HALF;
> +                               phydev->advertising |= SUPPORTED_10baseT_Half;
> +                       } else {
> +                               phydev->advertising &=
> +                                       ~(SUPPORTED_10baseT_Half);
> +                       }
> +
> +                       *mask |= ADVERTISE_10HALF;
> +               }
> +               if (!of_property_read_u32(np, "phy-mii-advertise-10full",
> +                                          &tmp)) {
> +                       if (tmp) {
> +                               *val |= ADVERTISE_10FULL;
> +                               phydev->advertising |= SUPPORTED_10baseT_Full;
> +                       } else {
> +                               phydev->advertising &=
> +                                       ~(SUPPORTED_10baseT_Full);
> +                       }
> +
> +                       *mask |= ADVERTISE_10FULL;
> +               }
> 

Just a style suggestion: rather than almost duplicating the same 12 lines
of code for each property, I think it can be split out into a helper
function.

	Arnd

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
