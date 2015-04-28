From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Tue, 28 Apr 2015 18:09:42 +0100
Message-ID: <1430240982.5802.30.camel@xylophone.i.decadent.org.uk>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
	 <552C4554.2070608@gmail.com> <552D8898.3060905@cogentembedded.com>
	 <55382D4E.5070708@gmail.com> <553A9123.3010906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <553A9123.3010906@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-04-24 at 21:53 +0300, Sergei Shtylyov wrote:
> On 04/23/2015 02:22 AM, Florian Fainelli wrote:
> 
> [...]
> 
> >>>> +    if (ecmd->duplex == DUPLEX_FULL)
> >>>> +        priv->duplex = 1;
> >>>> +    else
> >>>> +        priv->duplex = 0;
> 
> >>> Why not use what priv->phydev->duplex has cached for you?
> 
> >>     Because we compare 'priv->duplex' with 'priv->phydev->duplex' in
> >> ravb_adjust_link(). Or what did you mean?
> 
> > Oh I see how you are using this now, but it does not look like it is
> > necessary, since you use phy_ethtool_sset() using phydev->duplex
> 
>    It only writes to it, doesn't use it AFAICS...
> 
> > directly ought to be enough anywhere in your driver?
> 
>     'priv->phydev' is NULL when the device is closed, so I just can't call 
> phy_ethtool_sset().
> 
> > Unless there is a
> > mode where you are running PHY-less, and not using a fixed PHY to
> > emulate a PHY...
> 
>     No such mode.
> 
> >> [...]
> 
> >>>> +static int ravb_nway_reset(struct net_device *ndev)
> >>>> +{
> >>>> +    struct ravb_private *priv = netdev_priv(ndev);
> >>>> +    int error = -ENODEV;
> >>>> +    unsigned long flags;
> >>>> +
> >>>> +    if (priv->phydev) {
> 
> >>> Is checking against priv->phydev really necessary, it does not look like
> >>> the driver will work or accept an invalid PHY device at all anyway?
> 
>     This check was copied from sh_eth that was fixed by Ben ot to crash due to
> 'ethtool' being called on closed device, see:
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/renesas/sh_eth.c?id=4f9dce230b32eec45cec8c28cae61efdfa2f7d57
> 
>     That commit refers to a dangling pointer, not sure what does this mean...
> The PHy device doesn't seem to be freed by phy_disconnect(). Ben?
[...]

In practice the phy_device is unlikely to be freed immediately.  Bt it
is certainly not valid for a net driver to pass a phy_device pointer to
phylib functions after calling phy_disconnect() on it.

Ben.


