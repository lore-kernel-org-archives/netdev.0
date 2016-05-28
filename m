From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC v2 2/2] NET: PHY: lantiq: add LED configuration support
Date: Sun, 29 May 2016 00:03:23 +0200
Message-ID: <20160528220323.GD6027@lunn.ch>
References: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
 <1464454741-18557-2-git-send-email-hauke@hauke-m.de>
 <20160528182709.GJ23212@lunn.ch>
 <574A0C49.1010604@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53482 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734AbcE1WD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 18:03:29 -0400
Content-Disposition: inline
In-Reply-To: <574A0C49.1010604@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Do you know for which PHY I could implement this? I only have access to
> the documentation for the Lantiq / Intel PHYs.

Maybe actually implementing them is too far. But you could take a look
at available datasheets and thing about how you would implement the
binding. A quick search found:

http://www.davicom.com.tw/userfile/24247/DM9161-DS-F05_091008.pdf
http://www.o2xygen.com/photo/VSC8201XVZ/VSC8201XVZ_001.pdf
http://www.ti.com.cn/cn/lit/ds/symlink/dp83640.pdf
http://www.ti.com/lit/ds/symlink/dp83848-ep.pdf
http://ww1.microchip.com/downloads/en/DeviceDoc/KSZ8081MNX-RNB.pdf

Is what you have defined flexible enough?
 
> Should this documentation file be specific for this PHY driver or
> should I add two files for documentation one describing the generic
> interface and then an additional one describing the concrete
> capabilities of this PHY?

Yes, have a generic document which any PHY should be able to use, and
a specific one per PHY.

> I also thought about this, but as far as I know there is no standard
> interface for these properties. I think setting the max speed is
> standardized by the ieee. Should there be a callback with the
> information needed for the PHY driver? I think having the parsing in the
> generic code will not make the PHY driver much simpler, but we could
> later provide these settings for different places like change the
> configuration from user space.

What we don't want is X PHYs with Y different LED bindings. We should
be aiming to describe a binding which fits the majority of PHYs. And
since it should fit the majority of PHYs we can pull parts of it into
the infrastructure. That itself will prevent people doing something
different.

	Andrew
