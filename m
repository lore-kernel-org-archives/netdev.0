From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 17:27:46 +0100
Message-ID: <20141212162746.GJ16916@distanz.ch>
References: <1418400429-6680-1-git-send-email-tklauser@distanz.ch>
 <20141212161100.GH2950@atomide.com>
 <20141212.112119.1395396406830853805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony@atomide.com, nico@fluxnic.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:39529 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964851AbaLLQ1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 11:27:52 -0500
Content-Disposition: inline
In-Reply-To: <20141212.112119.1395396406830853805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 17:21:19 +0100, David Miller <davem@davemloft.net> wrote:
> From: Tony Lindgren <tony@atomide.com>
> Date: Fri, 12 Dec 2014 08:11:00 -0800
> 
> > * Tobias Klauser <tklauser@distanz.ch> [141212 08:09]:
> >> If GPIOLIB=n the following build errors occur:
> >> 
> >> drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
> >> drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
> >> drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> >> drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
> >> drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
> >> drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]
> >> 
> >> Since the toggling of the GPIOs is an optional feature, define
> >> try_toggle_control_gpio only if GPIOLIB is enabled.
> > 
> > Oops sorry about that, I guess my systems have it all selected so
> > randconfig builds did not expose it.
> > 
> > Would it make sense to add the missing gpio stub into
> > include/linux/gpio/consumer.h instead?
> 
> I really don't like these kinds of things at all.
> 
> If GPIO is required to fully program the hardware properly,
> the smc91x driver should have it as a dependency.

GPIO is not needed in all configurations of the chip, they are optional.
That's why I was going for the ugly #ifdef solution.

It seems that there are stubs for the functions in question in
linux/gpio/consumer.h already as Tony suggested. Thus, adding an
#include <linux/gpio/consumer.h> to the driver should be enough. I'll
send an updated patch.
