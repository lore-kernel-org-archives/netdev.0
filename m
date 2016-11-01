From: David Miller <davem@redhat.com>
Subject: Re: [PATCH -next] net: cris: make eth_v10.c explicitly non-modular
Date: Mon, 31 Oct 2016 20:58:50 -0400 (EDT)
Message-ID: <20161031.205850.2263808504938840791.davem@redhat.com>
References: <20161031193216.28154-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, starvik@axis.com, jesper.nilsson@axis.com,
        linux-cris-kernel@axis.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S948402AbcKAA6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 20:58:52 -0400
In-Reply-To: <20161031193216.28154-1-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 31 Oct 2016 15:32:16 -0400

> The Makefile/Kconfig currently controlling compilation of this code is:
> 
> drivers/net/cris/Makefile:obj-$(CONFIG_ETRAX_ARCH_V10) += eth_v10.o
> 
> arch/cris/Kconfig:config ETRAX_ARCH_V10
> arch/cris/Kconfig:       bool
> 
> ...meaning that it currently is not being built as a module by anyone.
> 
> Lets remove the couple traces of modular infrastructure use, so that
> when reading the driver there is no doubt it is builtin-only.
> 
> Since module_init translates to device_initcall in the non-modular
> case, the init ordering remains unchanged with this commit.
> 
> There was a one line wrapper for the int init function, which made no
> sense; hence we just put the device_initcall on the true init function
> itself and delete the pointless wrapper.  In doing that we get rid of
> the following compile warning:
> 
>    WARNING: drivers/net/built-in.o(.text+0x1e28): Section mismatch in
>    reference from the function etrax_init_module() to the function
>    .init.text:etrax_ethernet_init()
> 
> We don't replace module.h with init.h since the file already has that.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mikael Starvik <starvik@axis.com>
> Cc: Jesper Nilsson <jesper.nilsson@axis.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-cris-kernel@axis.com
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
