From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 01:44:50 -0700 (PDT)
Message-ID: <20130613.014450.1434692343011842828.davem@davemloft.net>
References: <1371066785-17168-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, blogic@openwrt.org,
	linux-mips@linux-mips.org, mbizon@freebox.fr, jogo@openwrt.org,
	cernekee@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757368Ab3FMIov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:44:51 -0400
In-Reply-To: <1371066785-17168-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 12 Jun 2013 20:53:05 +0100

> +#ifdef BCMCPU_RUNTIME_DETECT

I want the MIPS folks to fix this brain damange.

This runtime detect thing is just a big mess in a header file
using hundreds of lines of CPP stuff to express what is fundamentally
a simple (albeit sizable) Kconfig dependency.

And this ifdef virus spreads from that header file now into this
driver.

How can it possibly make sense to have this "maybe it's static at
build time, maybe it's dynamic" coded into every single piece of code
for platform drivers or any other thing related to this set of MIPSs
cpus?

It's rediculous, and I refuse to add code to my tree which continues
this trend, sorry.
