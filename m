From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: b53: avoid 'maybe-uninitialized' warning
Date: Wed, 29 Jun 2016 05:07:41 -0400 (EDT)
Message-ID: <20160629.050741.586321609893533046.davem@davemloft.net>
References: <20160627091926.1377587-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160627091926.1377587-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 27 Jun 2016 11:19:13 +0200

> In some configurations, gcc produces a warning for correct code
> in this driver:
 ...
> I have seen the warning before and at the time thought I had fixed
> it with 55e7f6abe131 ("dsa: b53: fix big-endian register access"),
> however it now came back in a different randconfig build that happens
> to have different inlining decisions in the compiler.
> 
> The mistake that gcc makes here is that it thinks the second call to
> readl() might fail because the address 'reg + 4' is not a multiple
> of four despite having knowing that 'reg' itself is a multiple of four.
> 
> By open-coding the two reads without the redundant alignment check,
> we can avoid the warning and produce slightly better object code, but
> get slightly longer source code instead.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
