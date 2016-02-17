From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Add support for phy-handle binding
Date: Wed, 17 Feb 2016 12:14:14 -0500 (EST)
Message-ID: <20160217.121414.529895298809970981.davem@davemloft.net>
References: <1455379368-18739-1-git-send-email-nathan@nathanrossi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nicolas.ferre@atmel.com
To: nathan@nathanrossi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455379368-18739-1-git-send-email-nathan@nathanrossi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Rossi <nathan@nathanrossi.com>
Date: Sun, 14 Feb 2016 02:02:48 +1000

> This patch adds support for the 'phy-handle' binding which allows for a
> system to specifically select a phy which can be attached via any MDIO
> bus available in the system.
> 
> Signed-off-by: Nathan Rossi <nathan@nathanrossi.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

I don't see how this can be backwards compatible at all.

In my opinion we are way too loose about handling things like this.

Existing chips that happened to have an OF node but lack a phy-handle
property are going to be broken by that change.

I know you are now going to bombard me with all kinds of reasons why
this won't happen.

Don't bother, I'm simply not interested.

All of these special cases we use (all the DT bindings are in text
files in the kernel sources, we control all of the bootloaders, etc.)
is the most shaky foundation I've ever seen upon which to erect a
stable device probing mechanism.

I'm not applying this patch until you add an error handling path from
the of_phy_connect() call that will do the existing PHY probing sequence
by hand using phy_find_first().
