From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net/phy/vitesse: Configure RGMII skew on VSC8601, if
 needed
Date: Wed, 16 Nov 2016 17:54:37 +0100
Message-ID: <20161116165437.GK23231@lunn.ch>
References: <20161115.221217.2076182289174952941.davem@davemloft.net>
 <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
 <20161116135053.GF19962@lunn.ch>
 <f05f5f5d-a010-def2-314a-09a859f9eda3@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        Gokhan Cosgul <gokhan@adaptrum.com>
To: Alex <alex.g@adaptrum.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f05f5f5d-a010-def2-314a-09a859f9eda3@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 08:44:30AM -0800, Alex wrote:
> 
> 
> On 11/16/2016 05:50 AM, Andrew Lunn wrote:
> >On Wed, Nov 16, 2016 at 01:02:33AM -0800, Alexandru Gagniuc wrote:
> >>With RGMII, we need a 1.5 to 2ns skew between clock and data lines. The
> >>VSC8601 can handle this internally. While the VSC8601 can set more
> >>fine-grained delays, the standard skew settings work out of the box.
> >>The same heuristic is used to determine when this skew should be enabled
> >>as in vsc824x_config_init().
> >>
> >>+/* This adds a skew for both TX and RX clocks, so the skew should only be
> >>+ * applied to "rgmii-id" interfaces. It may not work as expected
> >>+ * on "rgmii-txid", "rgmii-rxid" or "rgmii" interfaces. */
> >
> >Hi Alexandru
> >
> >You should be able to make "rgmii" work as expected. If that is the
> >phy mode, disable the skew.
> 
> And that's exactly the implemented behavior. See
> vsc8601_config_init() below.

I don't think so. vsc8601_config_init() will not cause the skew to be
cleared if the phy-mode is "rgmii" and something else like the
bootloader could of set the skew. So saying that "rgmii" might not
work as expected is true. But with a minor change, you can make it
work as expected.

	Andrew
