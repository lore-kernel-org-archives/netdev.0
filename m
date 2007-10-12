From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.24 breaks powerpc mysteriously
Date: Thu, 11 Oct 2007 19:22:33 -0700
Message-ID: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>,
	Paul Mackerras <paulus@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40739 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752762AbXJLCWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 22:22:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With net-2.6.24 (pulled yesterday) applied:

g5:/usr/src/25> ml arch/powerpc/boot/inflate.o
  Using ARCH=powerpc CROSS_COMPILE=
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  BOOTCC  arch/powerpc/boot/inflate.o
arch/powerpc/boot/inflate.c:920:19: errno.h: No such file or directory
arch/powerpc/boot/inflate.c:921:18: slab.h: No such file or directory
arch/powerpc/boot/inflate.c:922:21: vmalloc.h: No such file or directory
arch/powerpc/boot/inflate.c: In function `zlib_inflate_blob':
arch/powerpc/boot/inflate.c:928: error: syntax error before '*' token
arch/powerpc/boot/inflate.c:932: error: `ENOMEM' undeclared (first use in this function)
arch/powerpc/boot/inflate.c:932: error: (Each undeclared identifier is reported only once
arch/powerpc/boot/inflate.c:932: error: for each function it appears in.)
arch/powerpc/boot/inflate.c:933: warning: implicit declaration of function `kmalloc'
arch/powerpc/boot/inflate.c:933: error: `GFP_KERNEL' undeclared (first use in this function)
arch/powerpc/boot/inflate.c:933: warning: assignment makes pointer from integer without a cast
arch/powerpc/boot/inflate.c:936: warning: assignment makes pointer from integer without a cast
arch/powerpc/boot/inflate.c:943: error: `zbuf' undeclared (first use in this function)
arch/powerpc/boot/inflate.c:955: error: `EINVAL' undeclared (first use in this function)
arch/powerpc/boot/inflate.c:960: warning: implicit declaration of function `kfree'

without it applied:

g5:/usr/src/25> ml arch/powerpc/boot/inflate.o
scripts/kconfig/conf -s arch/powerpc/Kconfig
#
# configuration written to .config
#
  Using ARCH=powerpc CROSS_COMPILE=
  HOSTCC  scripts/mod/file2alias.o
  HOSTCC  scripts/mod/modpost.o
  HOSTLD  scripts/mod/modpost
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CC      arch/powerpc/kernel/asm-offsets.s
  GEN     include/asm-powerpc/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  COPY    arch/powerpc/boot/zlib.h
  COPY    arch/powerpc/boot/inflate.c
  BOOTCC  arch/powerpc/boot/inflate.o
.config:308:warning: trying to assign nonexistent symbol INET_LRO
.config:638:warning: trying to assign nonexistent symbol VETH
.config:639:warning: trying to assign nonexistent symbol IP1000

Note that those two COPY commands didn't happen with net-2.6.24 applied, although
that might be because `make' decided they were already performed, dunno.

I also have today's git-kbuild applied here, as well as yesterday's git-powerpc.

But I have enough to fix here so I'm going to do a report-and-run on this one.
I'll release 2.6.23-mm1 in this state for your bug-hunting convenience ;)
