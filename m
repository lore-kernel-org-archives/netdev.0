From: Olof Johansson <olof@lixom.net>
Subject: Re: [RFC] phy: micrel: Convert micrel PHY driver to use OF
Date: Wed, 21 Aug 2013 22:13:47 -0700
Message-ID: <20130822051347.GD5151@quad.lixom.net>
References: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dinh.linux@gmail.com, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Rob Herring <rob.herring@calxeda.com>,
	devicetree@vger.kernel.org
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:50190 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab3HVFO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 01:14:28 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so1291036pbc.8
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 22:14:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1376412156-3899-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding devicetree@vger.kernel.org)


On Tue, Aug 13, 2013 at 11:42:36AM -0500, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Convert the Micrel PHY driver to use OF. This initial patch is only
> the beginning of an idea to convert the PHY driver to device tree.
> 
> Signed-of-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: netdev@vger.kernel.org
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: Linus Walleij <linus.walleij@linaro.org>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Olof Johansson <olof@lixom.net>
> Cc: Rob Herring <rob.herring@calxeda.com>
> 
> ---
> Hello,
> 
> I would like to solicit comments on the need to convert the ethernet PHY
> drivers to use OF/device trees? For the platform that I'm interested in,
> SOCFPGA, it is using the stmicro ethernet driver. It has a Micrel PHY
> on the board. The only way that I know of how to change the skew settings
> for the phy is through a board level initialization.
> 
> One of the ARM maintainers suggested that perhaps refactoring the ethernet
> driver to use device tree would be nice. But that would not help me with
> configuring the PHY settings.
> 
> So a little investigation led me to believe that refactoring the /net/phy
> drivers into a device tree implementation would help greatly. I was thinking
> it could be done like the pinctrl or some of the usb/phy driver.
> 
> Since I am only familiar with the ARM SoC space, I want to make sure that
> this idea is right approach. I can start with the micrel PHY driver
> first, as that is the only HW I have access to.

Hi,

Sorry for the slow reply here.

I don't think this is quite the right approach.

What you want to do is to make the phy devices register based on device tree
contents, which also means removing the run function, or rather moving it to
a generic run function in the phy subsystem that acts based on device tree
contents instead of a hard-coded per-board run function.

It sounds like defining that binding might end up getting complicated.
I suggest you consider recruiting some of the more seasoned devicetree folks on
this endeavor.

It's possible that you'll mostly have per-vendor/phy type properties to tune
the various settings, but it's also likely that you will have some generic and
shared (optional) properties such as gpios for resetting, or regulators for
powering, the phy.


-Olof
