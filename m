From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed, 7 Jun 2017 16:56:36 +0100
Message-ID: <20170607155636.GK4902@n2100.armlinux.org.uk>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-8-antoine.tenart@free-electrons.com>
 <e423ea96-12df-6a19-ce94-149ace2e2272@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        mw@semihalf.com, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:42050 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdFGP44 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 11:56:56 -0400
Content-Disposition: inline
In-Reply-To: <e423ea96-12df-6a19-ce94-149ace2e2272@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 08:48:06AM -0700, Florian Fainelli wrote:
> On 06/07/2017 01:38 AM, Antoine Tenart wrote:
> > This patch adds the xMDIO interface support in the mvmdio driver. This
> > interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> > of now). The xSMI interface supported by this driver complies with the
> > IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> > 22). The xSMI interface is used by 10GbE devices.
> > 
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> > ---
> 
> > +	if (of_device_is_compatible(np, "marvell,orion-mdio")) {
> > +		ops->is_done = smi_is_done;
> > +		ops->is_read_valid = smi_is_read_valid;
> > +		ops->start_read = smi_start_read_op;
> > +		ops->read = smi_read_op;
> > +		ops->write = smi_write_op;
> > +
> > +		dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
> > +		dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
> > +	} else if (of_device_is_compatible(np, "marvell,xmdio")) {
> > +		ops->is_done = xsmi_is_done;
> > +		ops->is_read_valid = xsmi_is_read_valid;
> > +		ops->start_read = xsmi_start_read_op;
> > +		ops->read = xsmi_read_op;
> > +		ops->write = xsmi_write_op;
> > +
> > +		dev->poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN;
> > +		dev->poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX;
> > +	} else {
> > +		return -EINVAL;
> > +	}
> 
> Instead of doing this, you could have the ops structure declared e.g: a
> static global variables in the driver and reference them from the
> of_device_id .data field, something like:
> 
> static struct orion_mdio_ops mdio_ops = {
> 	...
> };

In this case, don't forget the "const" for static structures containing
only function pointers (so that the function pointers can't be exploited.)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
