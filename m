From: Andi Kleen <ak@suse.de>
Subject: Re: fib_hash.c:fn_hash()
Date: Thu, 24 Jun 2004 12:39:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624103905.GB16727@wotan.suse.de>
References: <20040624010938.55f90500.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040624010938.55f90500.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 24, 2004 at 01:09:38AM -0700, Andrew Morton wrote:
> 
> Current gcc CVS emits a memmove() when compiling this function, and the
> kernel link fails.

It's just an i386 bug. Other architectures have a proper out of line
memmove.

I would suggest to just not define __HAVE_ARCH_MEMMOVE, then lib/string.c
will do the right thing.

BTW if we don't want to supply these functions we should change
the kernel to compile with -ffreestanding. But so far at least 
the common ports are good enough at that now that it isn't needed.

-Andi

Here's a patch: Or perhaps it would be better to just remove
this completely from asm/string.h, since I can see no sane reason
to inline memmove(). That would make the kernel smaller.


diff -u linux/include/asm-i386/string.h-o linux/include/asm-i386/string.h
--- linux/include/asm-i386/string.h-o	2004-03-21 21:11:56.000000000 +0100
+++ linux/include/asm-i386/string.h	2004-06-24 12:38:25.000000000 +0200
@@ -293,7 +293,7 @@
 	memcpy(x, y, sizeof(*(x)));		\
 })
 
-#define __HAVE_ARCH_MEMMOVE
+#ifndef IN_STRING_C
 static inline void * memmove(void * dest,const void * src, size_t n)
 {
 int d0, d1, d2;
@@ -312,6 +312,7 @@
 	:"memory");
 return dest;
 }
+#endif
 
 #define memcmp __builtin_memcmp
 
