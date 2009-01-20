From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB
 transfers
Date: Tue, 20 Jan 2009 14:47:19 -0800 (PST)
Message-ID: <20090120.144719.120709836.davem@davemloft.net>
References: <34115.192.168.0.40.1232483361.squirrel@server>
	<200901202345.47792.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762166AbZATWrb@vger.kernel.org>
In-Reply-To: <200901202345.47792.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 20 Jan 2009 23:45:47 +0100

> On Tuesday 20 January 2009, you wrote:
> > From: Christian Eggers <christian.eggers@kathrein.de>
> > 
> > mcs7830_set_reg() and mcs7830_get_reg() are called with buffers
> > from stack which must not be used directly for USB transfers.
> > This causes corruption of the stack particulary on non x86
> > architectures because DMA may be used for these transfers.
> > 
> > Signed-off-by: Christian Eggers <christian.eggers@kathrein.de>
> 
> Have you observed problems with this, or just suspected trouble?

Yes, this is in response to SH platform failures.

You cannot DMA from/to the kernel stack, because it might not be in
the aliased linear mapping of physical memory.  It could even be
vmalloc()'d memory on some platforms.
