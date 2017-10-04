From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net 0/9] Fixes, cleanup and modernization for
 some legacy ethernet NIC drivers
Date: Tue, 03 Oct 2017 21:41:21 -0700 (PDT)
Message-ID: <20171003.214121.339749620339054592.davem@davemloft.net>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Mon,  2 Oct 2017 21:07:17 -0400 (EDT)

> This patch series fixes some logging bugs and adds some missing message
> severity levels.
> 
> There are also cleanup patches for dead code and some Kconfig cruft.
> 
> Custom debug message logging is converted to netif_* calls to reduce
> code duplication.
> 
> All up, about 150 lines of code are eliminated.
> 
> My apologies for duplicated messages. I messed up the addressing.

Finn, I'm finding real bugs in this series and seriously if you cannot
test these changes in some way please leave this code alone.

For example, you're removing the "once_is_enough" logic from
mac89x0_probe().

But you can't do that.  The probe function can in fact be called
multiple times, from drivers/net/Space.c  It gets called in a loop
iterating over different 'unit' argument values.

Unless you're making stylistic changes where you can prove the object
code resulting is still the same, you really should not be playing
with fire by trying to remove "dead code" like this in legacy drivers
you cannot fully test.

Thank you.
