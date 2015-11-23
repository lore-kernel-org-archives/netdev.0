From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 48/50] net/dsa/dsa.c:783:16: error: implicit
 declaration of function 'gpio_to_desc'
Date: Mon, 23 Nov 2015 15:16:56 -0500 (EST)
Message-ID: <20151123.151656.793660463195885617.davem@davemloft.net>
References: <201511240149.QARg1aGT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbKWUQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:16:58 -0500
In-Reply-To: <201511240149.QARg1aGT%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Tue, 24 Nov 2015 01:34:51 +0800

> All error/warnings (new ones prefixed by >>):
> 
>    net/dsa/dsa.c: In function 'dsa_of_probe':
>>> net/dsa/dsa.c:783:16: error: implicit declaration of function 'gpio_to_desc' [-Werror=implicit-function-declaration]
>        cd->reset = gpio_to_desc(gpio);
>                    ^
>>> net/dsa/dsa.c:783:14: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
>        cd->reset = gpio_to_desc(gpio);
>                  ^
>>> net/dsa/dsa.c:784:4: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
>        gpiod_direction_output(cd->reset, 0);
>        ^
>    cc1: some warnings being treated as errors

It looks like these specific gpio interfaces are not designed such
that we get default do-nothing versions when CONFIG_GPIO is not set.

Andrew, you'll have to cope with this somehow.  Perhaps add the
missing cases to include/asm-generic/gpio.h CPP #else branch.
