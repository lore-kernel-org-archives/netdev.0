From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Mon, 9 Jun 2008 17:19:45 -0700
Message-ID: <20080609171945.d2360114.akpm@linux-foundation.org>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
	<20080610001329.GA16197@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	alan@redhat.com, randy.dunlap@oracle.com
To: Alan Cox <alan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40607 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752392AbYFJAUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 20:20:24 -0400
In-Reply-To: <20080610001329.GA16197@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Jun 2008 20:13:29 -0400
Alan Cox <alan@redhat.com> wrote:

> To be clearer on this
> 
> > +obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
> 
> That line is wrong. Perhaps Andrew could post the original split patches
> instead ?

iirc this is your original, plus Randy's fix:

From: Randy Dunlap <randy.dunlap@oracle.com>

ne2 (MCA) needs both 8390.o and 8390p.o functions:

drivers/built-in.o: In function `ne_close':
ne2.c:(.text+0x30544): undefined reference to `eip_close'
drivers/built-in.o: In function `ne_open':
ne2.c:(.text+0x30554): undefined reference to `eip_open'
drivers/built-in.o: In function `ne2_probe':
(.init.text+0x1bce): undefined reference to `__alloc_eip_netdev'
drivers/built-in.o: In function `ne2_probe':
(.init.text+0x1dd9): undefined reference to `eip_interrupt'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/Makefile~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core-fix drivers/net/Makefile
--- a/drivers/net/Makefile~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core-fix
+++ a/drivers/net/Makefile
@@ -107,7 +107,7 @@ obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
 obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
-obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o
+obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
 obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
_


> > diff -puN drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/ne2.c
> > --- a/drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
> > +++ a/drivers/net/ne2.c
> 
> And this has a single missed ei to eip conversion.

Where?  Will that fix the build error?
