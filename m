From: Paul Mackerras <paulus@samba.org>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Fri, 12 Oct 2007 13:52:14 +1000
Message-ID: <18190.61294.191189.193153@cargo.ozlabs.ibm.com>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54241 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbXJLEJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 00:09:58 -0400
In-Reply-To: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton writes:

> arch/powerpc/boot/inflate.c:920:19: errno.h: No such file or directory
> arch/powerpc/boot/inflate.c:921:18: slab.h: No such file or directory
> arch/powerpc/boot/inflate.c:922:21: vmalloc.h: No such file or directory

We used to have our own copies of inflate.c etc. for the zImage
wrapper code to use under arch/powerpc/boot.  Then someone said "why
do we have two copies of these files?" and did a patch to make the
build process copy the files from lib/zlib_inflate over and compile
them.  (We can't just use the compiled .o files from lib/zlib_inflate
because the wrapper is 32-bit whereas the kernel is often 64-bit.)

Now it seems someone has made changes to the lib/zlib_inflate versions
that are OK in the context of the kernel but not in the zImage (which
is a separate program).  Avoiding this kind of breakage was the reason
why I made arch/powerpc/boot have its own copies originally.

So Andrew, what do you think is better - arch/powerpc/boot having its
own copies of the zlib_inflate stuff, or #ifdefs of some kind in
lib/zlib_inflate/*.c?

Paul.
