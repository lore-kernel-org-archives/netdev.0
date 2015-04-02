From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Thu, 02 Apr 2015 14:56:39 +0100
Message-ID: <1427982999.18722.35.camel@xylophone.i.decadent.org.uk>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver looks somewhat similar to sh-eth, but lacks some of the
recent bug fixes made to that.  At least commit 283e38db65e7 ("sh_eth:
Fix serialisation of interrupt disable with interrupt & NAPI handler")
appears to be applicable, but there are probably others.

One feature request:

On Sat, 2015-03-28 at 02:13 +0300, Sergei Shtylyov wrote:
[...]
> +/* ioctl to device function */
> +static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = priv->phydev;
> +
> +	if (!netif_running(ndev))
> +		return -EINVAL;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	if (cmd == SIOCSHWTSTAMP)
> +		return ravb_hwtstamp_ioctl(ndev, req, cmd);
[...]

The driver should also handle SIOCGHWTSTAMP.

Ben.


