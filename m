From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: linux-next: Tree for August 6 (8390 et al)
Date: Thu, 7 Aug 2008 10:29:31 +0100
Message-ID: <20080807102931.1bb0607d@lxorguk.ukuu.org.uk>
References: <20080806182828.6bfe0a16.sfr@canb.auug.org.au>
	<20080806172148.7fac5999.randy.dunlap@oracle.com>
	<Pine.LNX.4.64.0808070918510.17614@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808070918510.17614@anakin>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2008 09:20:07 +0200 (CEST)
Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> On Wed, 6 Aug 2008, Randy Dunlap wrote:
> > One randconfig ends with:
> > 
> > drivers/built-in.o: In function `wd_probe1':
> > wd.c:(.init.text+0x6179): undefined reference to `NS8390p_init'
> > make[1]: *** [.tmp_vmlinux1] Error 1
> 
> drivers/net/Makefile has:
> 
> obj-$(CONFIG_WD80x3) += wd.o 8390.o
> 
> So either wd_probe1() should call NS8390_init(), or obj-$(CONFIG_WD80x3)
> should link with 8390p.o. Don't know which is the appropriate change
> here (my gut feeling says the latter).

Safest is the latter. The shared memory interface on the wd is full speed
8 or 16bit (depending on card/jumpers) but I'm not clear about the NIC.
Most of the performance hit is on the packet transfer which is private
methods on this device so using 8390p won't make a big difference on this
board anyway.
