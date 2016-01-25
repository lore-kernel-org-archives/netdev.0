From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: simplify napi_synchronize() to avoid warnings
Date: Sun, 24 Jan 2016 22:20:12 -0800 (PST)
Message-ID: <20160124.222012.1063840610459462933.davem@davemloft.net>
References: <2817787.9jKELuxj8h@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxime.ripard@free-electrons.com,
	gregory.clement@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbcAYGUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 01:20:13 -0500
In-Reply-To: <2817787.9jKELuxj8h@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 22 Jan 2016 11:43:44 +0100

> The napi_synchronize() function is defined twice: The definition
> for SMP builds waits for other CPUs to be done, while the uniprocessor
> variant just contains a barrier and ignores its argument.
> 
> In the mvneta driver, this leads to a warning about an unused variable
> when we lookup the NAPI struct of another CPU and then don't use it:
> 
> ethernet/marvell/mvneta.c: In function 'mvneta_percpu_notifier':
> ethernet/marvell/mvneta.c:2910:30: error: unused variable 'other_port' [-Werror=unused-variable]
> 
> There are no other CPUs on a UP build, so that code never runs, but
> gcc does not know this.
> 
> The nicest solution seems to be to turn the napi_synchronize() helper
> into an inline function for the UP case as well, as that leads gcc to
> not complain about the argument being unused. Once we do that, we can
> also combine the two cases into a single function definition and use
> if(IS_ENABLED()) rather than #ifdef to make it look a bit nicer.
> 
> The warning first came up in linux-4.4, but I failed to catch it
> earlier.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f86428854480 ("net: mvneta: Statically assign queues to CPUs")

I guess this is fine, applied, thanks Arnd.
