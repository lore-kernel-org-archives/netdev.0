From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH] Do not include linux/irq.h from linux/netpoll.h
Date: Tue, 16 Mar 2004 00:11:41 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316001141.C29594@flint.arm.linux.org.uk>
References: <1079369568.19012.100.camel@icampbell-debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <icampbell@arcom.com>, netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
In-Reply-To: <1079369568.19012.100.camel@icampbell-debian>; from icampbell@arcom.com on Mon, Mar 15, 2004 at 04:52:50PM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 15, 2004 at 04:52:50PM +0000, Ian Campbell wrote:
> The culprit would appear to be the addition of a 
> 	#include <linux/netpoll.h>
> to net/core/dev.c which in turn pulls in <linux/irq.h> which (as Russell
> King notes in a comment therein) should not be included from generic
> code.

Linus - I haven't tested this patch myself yet, but I do think something
needs to happen with linux/irq.h.  It seems a comment in the file isn't
sufficient.

The file itself is misplaced and misleading sitting in the include/linux
subdirectory, which causes problems when people decide to include it into
architecture independent files, in the belief that it's a generic include
file.

I believe that linux/irq.h should at least become asm-generic/irq.h to
stop this happening.

What are your thoughts on this?

(Unfortunately, bkbits browsing using lynx or links seems to be rather
broken at the moment, otherwise I'd have checked whether you've already
integrated this patch.)

Index: linux-2.6-bkpxa/include/linux/netpoll.h
===================================================================
--- linux-2.6-bkpxa.orig/include/linux/netpoll.h        2004-03-15 15:03:30.000000000 +0000
+++ linux-2.6-bkpxa/include/linux/netpoll.h     2004-03-15 16:24:25.000000000 +0000
@@ -9,7 +9,6 @@
  
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
-#include <linux/irq.h>
 #include <linux/list.h>
  
 struct netpoll;

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
