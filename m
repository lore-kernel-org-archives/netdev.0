From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 1/7] net: dsa: add new driver for ar8xxx family
Date: Fri, 29 May 2015 04:08:54 +0200
Message-ID: <20150529020854.GG11260@lunn.ch>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <1432863742-18427-2-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org,
	gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org,
	fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1432863742-18427-2-git-send-email-mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
> +{
> +	int reg;
> +
> +	switch (port) {
> +	case 0:
> +		reg = AR8327_REG_PORT0_PAD_CTRL;
> +		break;
> +	case 6:
> +		reg = AR8327_REG_PORT6_PAD_CTRL;
> +		break;
> +	default:
> +		pr_err("Can't set PAD_CTRL on port %d\n", port);
> +		return -EINVAL;
> +	}
> +
> +	/* DSA only supports 1 CPU port for now, so we'll take the assumption
> +	 * that P0 is connected to the CPU master_dev.
> +	 */

I don't like this assumption. Hardware i have with Marvell switches
has the CPU connected to ports 5, or 6, or 0.

Calling dsa_upstream_port() will tell you which is the CPU port.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
