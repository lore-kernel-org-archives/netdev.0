From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 8 Apr 2016 02:53:17 +0200
Message-ID: <20160408005317.GA28125@lunn.ch>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop>
 <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
 <5706B4EF.2050600@codeaurora.org>
 <20160407201009.GA16136@lunn.ch>
 <5706D493.8020700@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5706D493.8020700@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2016 at 04:43:47PM -0500, Timur Tabi wrote:
> On my platform, firmware (UEFI) configures all of the GPIOs.  I need
> to get confirmation, but it appears that we don't actually make any
> GPIO calls at all.  I see code that looks like this:
> 
> 	for (i = 0; (!adpt->no_mdio_gpio) && i < EMAC_NUM_GPIO; i++) {
> 		gpio_info = &adpt->gpio_info[i];
> 		retval = of_get_named_gpio(node, gpio_info->name, 0);
> 		if (retval < 0)
> 			return retval;
> 
> And on our ACPI system, adpt->no_mdio_gpio is always true:
> 
> 	/* Assume GPIOs required for MDC/MDIO are enabled in firmware */
> 	adpt->no_mdio_gpio = true;

There are two different things here. One is configuring the pin to be
a GPIO. The second is using the GPIO as a GPIO. In this case,
bit-banging the MDIO bus.

The firmware could be doing the configuration, setting the pin as a
GPIO. However, the firmware cannot be doing the MDIO bit-banging to
make an MDIO bus available. Linux has to do that.

Or it could be we have all completely misunderstood the hardware, and
we are not doing bit-banging GPIO MDIO. There is a real MDIO
controller there, we don't use these pins as GPIOs, etc....

	   Andrew
