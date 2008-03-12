From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] ne2: needs more 8390 support functions
Date: Tue, 11 Mar 2008 21:51:10 -0700
Message-ID: <20080311215110.5215cc4d.akpm@linux-foundation.org>
References: <20080311095643.01cd3708.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, alan@lxorguk.ukuu.org.uk,
	jgarzik <jgarzik@pobox.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47725 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbYCLEv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 00:51:58 -0400
In-Reply-To: <20080311095643.01cd3708.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Mar 2008 09:56:43 -0700 Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> ne2 (MCA) needs both 8390.o and 8390p.o functions:
> 
> drivers/built-in.o: In function `ne_close':
> ne2.c:(.text+0x30544): undefined reference to `eip_close'
> drivers/built-in.o: In function `ne_open':
> ne2.c:(.text+0x30554): undefined reference to `eip_open'
> drivers/built-in.o: In function `ne2_probe':
> (.init.text+0x1bce): undefined reference to `__alloc_eip_netdev'
> drivers/built-in.o: In function `ne2_probe':
> (.init.text+0x1dd9): undefined reference to `eip_interrupt'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/Makefile |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.25-rc5-mm1.orig/drivers/net/Makefile
> +++ linux-2.6.25-rc5-mm1/drivers/net/Makefile
> @@ -108,7 +108,7 @@ obj-$(CONFIG_68360_ENET) += 68360enet.o
>  obj-$(CONFIG_WD80x3) += wd.o 8390.o
>  obj-$(CONFIG_EL2) += 3c503.o 8390p.o
>  obj-$(CONFIG_NE2000) += ne.o 8390p.o
> -obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o
> +obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o
>  obj-$(CONFIG_HPLAN) += hp.o 8390p.o
>  obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
>  obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o

I have a note here that there's something busted about
8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core.patch
but I do not recall what it was.  The details languish in Alan's inbox
somewhere from around February.

I wonder if this was it, and if that was the only bug.
