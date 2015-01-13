From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: avoid arch specific __builtin_return_address
 call
Date: Tue, 13 Jan 2015 17:08:47 -0500 (EST)
Message-ID: <20150113.170847.166125234153799669.davem@davemloft.net>
References: <1816278.9Bv8N8K5IB@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	isdn@linux-pingi.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1816278.9Bv8N8K5IB@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 13 Jan 2015 17:10:58 +0100

> Not all architectures are able to call __builtin_return_address().
> On ARM, the mISDN code produces this warning:
> 
> hardware/mISDN/w6692.c: In function 'w6692_dctrl':
> hardware/mISDN/w6692.c:1181:75: warning: unsupported argument to '__builtin_return_address'
>   pr_debug("%s: %s dev(%d) open from %p\n", card->name, __func__,
>                                                                            ^
> hardware/mISDN/mISDNipac.c: In function 'open_dchannel':
> hardware/mISDN/mISDNipac.c:759:75: warning: unsupported argument to '__builtin_return_address'
>   pr_debug("%s: %s dev(%d) open from %p\n", isac->name, __func__,
>                                                                            ^
> 
> In a lot of cases, this is relatively easy to work around by
> passing the value of __builtin_return_address(0) from the
> callers into the functions that want it. One exception is
> the indirect 'open' function call in struct isac_hw. While it
> would be possible to fix this as well, this patch only addresses
> the other callers properly and lets this one return the direct
> parent function, which should be good enough.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
