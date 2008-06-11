From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Wed, 11 Jun 2008 11:25:01 -0700
Message-ID: <20080611112501.152da143.randy.dunlap@oracle.com>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
	<20080610001329.GA16197@devserv.devel.redhat.com>
	<20080609171945.d2360114.akpm@linux-foundation.org>
	<20080610112013.219fedda@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@redhat.com>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59899 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbYFKSZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 14:25:57 -0400
In-Reply-To: <20080610112013.219fedda@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2008 11:20:13 +0100 Alan Cox wrote:

> On Mon, 9 Jun 2008 17:19:45 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Mon, 9 Jun 2008 20:13:29 -0400
> > Alan Cox <alan@redhat.com> wrote:
> > 
> > > To be clearer on this
> > > 
> > > > +obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
> > > 
> > > That line is wrong. Perhaps Andrew could post the original split patches
> > > instead ?
> > 
> > iirc this is your original, plus Randy's fix:
> 
> This corrects Randy's fix. The ne2.c code you have is actually correct
> just the Makefile wrong. Not sure where the original NAK/diff went but they
> aren't in the lkml archive either so they obviously got eaten somewhere my
> end.
> 
> 8390: fix problems in the original split patch
> 
> From: Alan Cox <alan@redhat.com>
> 
> The split patch didn't fully convert the ne2 driver so it failed to link. At
> some point this was fixed but the Makefile also got changed to incorrectly
> link with both 8390 and 8390p. Only 8390p is needed so remove 8390.o references
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> ---
> 
>  drivers/net/Makefile |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 41b239a..388cab8 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -107,7 +107,7 @@ obj-$(CONFIG_68360_ENET) += 68360enet.o
>  obj-$(CONFIG_WD80x3) += wd.o 8390.o
>  obj-$(CONFIG_EL2) += 3c503.o 8390p.o
>  obj-$(CONFIG_NE2000) += ne.o 8390p.o
> -obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
> +obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
>  obj-$(CONFIG_HPLAN) += hp.o 8390p.o
>  obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
>  obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o


Replacing my patch with this one yields:

drivers/built-in.o: In function `ne_block_output':
/local/linsrc/linux-2.6.26-rc5-mm2/drivers/net/ne2.c:751: undefined reference to `NS8390_init'
drivers/built-in.o: In function `ne2_probe1':
/local/linsrc/linux-2.6.26-rc5-mm2/drivers/net/ne2.c:502: undefined reference to `NS8390_init'
make[1]: *** [.tmp_vmlinux1] Error 1

for ne2 driver built into kernel image.
