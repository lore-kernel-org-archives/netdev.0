From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] uapi glibc compat: fix musl libc compatibility
Date: Thu, 20 Apr 2017 16:07:39 -0400 (EDT)
Message-ID: <20170420.160739.1263793303398330801.davem@davemloft.net>
References: <20170418210036.26039-1-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
        dwmw2@infradead.org
To: hauke@hauke-m.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418210036.26039-1-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Tue, 18 Apr 2017 23:00:33 +0200

> The code from libc-compat.h depends on some glibc specific defines and 
> causes compile problems with the musl libc. These patches remove some 
> of the glibc dependencies. With these patches the LEDE (OpenWrt) base 
> user space applications can be build with unmodified kernel headers and 
> musl libc.
> 
> This was compile tested with the user space from LEDE (OpenWrt) with 
> musl 1.1.16, glibc 2.25 and uClibc-ng 1.0.22.
> 
> Changes since v1:
>  - fix typo in commit message
>  - combine two changes

I think I have to put the brakes on this patch series, after much
consideration.

It does not scale if we continually add a hodge-podge of different
ifdef tests to the UAPI headers in order to prevent mutliple
definitions.

We will add that IFF_ECHO ifdef for MUSL libc today, and for another
libc we will add another such hack.  And so on and so forth...

Instead, LIBC implementation must adopt the ifdef protections which
have standard names and are being adopted by GLIBC and hopefully
others.

So please instead adjust the musl headers so that they interact
properly with the framework we've designed specifically for this
purpose.

Thank you.
