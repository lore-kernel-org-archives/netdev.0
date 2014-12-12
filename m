From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 11:21:19 -0500 (EST)
Message-ID: <20141212.112119.1395396406830853805.davem@davemloft.net>
References: <1418400429-6680-1-git-send-email-tklauser@distanz.ch>
	<20141212161100.GH2950@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, nico@fluxnic.net, netdev@vger.kernel.org
To: tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030554AbaLLQVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:21:21 -0500
In-Reply-To: <20141212161100.GH2950@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Lindgren <tony@atomide.com>
Date: Fri, 12 Dec 2014 08:11:00 -0800

> * Tobias Klauser <tklauser@distanz.ch> [141212 08:09]:
>> If GPIOLIB=n the following build errors occur:
>> 
>> drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
>> drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
>> drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
>> drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
>> drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
>> drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]
>> 
>> Since the toggling of the GPIOs is an optional feature, define
>> try_toggle_control_gpio only if GPIOLIB is enabled.
> 
> Oops sorry about that, I guess my systems have it all selected so
> randconfig builds did not expose it.
> 
> Would it make sense to add the missing gpio stub into
> include/linux/gpio/consumer.h instead?

I really don't like these kinds of things at all.

If GPIO is required to fully program the hardware properly,
the smc91x driver should have it as a dependency.
