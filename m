From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 0/4 v3 net-next] tg3: Add hwmon support
Date: Mon, 13 Aug 2012 17:37:11 +1000
Message-ID: <1344843431.2698.63.camel@pasglop>
References: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
	 <20120716.231128.1113699431084132190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56648 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab2HMHhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 03:37:55 -0400
In-Reply-To: <20120716.231128.1113699431084132190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 23:11 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Mon, 16 Jul 2012 19:23:58 -0700
> 
> > David, I've removed the binary sysfs attribute and now use
> > hwmon only.  Please consider this patchset for net-next.
> 
> Applied, thanks Michael.
> 
> You might want to add some Kconfig logic so that it's easier
> to get the hwmon stuff automatically when tg3 is selected.

Right, just got bitten by that one with one of my test configs:

CONFIG_TIGON3=y
CONFIG_HWMON=m

results in:

drivers/built-in.o: In function `.tg3_close':
tg3.c:(.text+0x1ab664): undefined reference to `.hwmon_device_unregister'
drivers/built-in.o: In function `.tg3_hwmon_open':
tg3.c:(.text+0x1b153c): undefined reference to `.hwmon_device_register'

I hit a similar one a while back with some DRM driver, there's no
nice way to solve them afaik, other than basically forcing HWMON to
y if TIGON3 is enabled. Either that, or having TIGON3's hwmon support
be a sub-option itself dependent on CONFIG_HWMON & potentially build
as a separate module etc... quite a pain.

Cheers,
Ben.
