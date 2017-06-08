From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ila_xlat: add missing hash secret initialization
Date: Thu, 08 Jun 2017 15:37:35 -0400 (EDT)
Message-ID: <20170608.153735.449425073256387555.davem@davemloft.net>
References: <20170608075448.2076975-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608075448.2076975-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu,  8 Jun 2017 09:54:24 +0200

> While discussing the possible merits of clang warning about unused initialized
> functions, I found one function that was clearly meant to be called but
> never actually is.
> 
> __ila_hash_secret_init() initializes the hash value for the ila locator,
> apparently this is intended to prevent hash collision attacks, but this ends
> up being a read-only zero constant since there is no caller. I could find
> no indication of why it was never called, the earliest patch submission
> for the module already was like this. If my interpretation is right, we
> certainly want to backport the patch to stable kernels as well.
> 
> I considered adding it to the ila_xlat_init callback, but for best effect
> the random data is read as late as possible, just before it is first used.
> The underlying net_get_random_once() is already highly optimized to avoid
> overhead when called frequently.
> 
> Fixes: 7f00feaf1076 ("ila: Add generic ILA translation facility")
> Cc: stable@vger.kernel.org
> Link: https://www.spinics.net/lists/kernel/msg2527243.html
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Yikes, good catch, applied and queued up for -stable.
