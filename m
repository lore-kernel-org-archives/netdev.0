From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Wed, 7 Feb 2007 10:56:04 +0100
Message-ID: <200702071056.04879.dada1@cosmosbay.com>
References: <200702061536.18800@nienna> <20070206.131908.13769204.davem@davemloft.net> <p73ireemgwm.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:60925 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161121AbXBGK2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 05:28:51 -0500
In-Reply-To: <p73ireemgwm.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 February 2007 10:54, Andi Kleen wrote:
> David Miller <davem@davemloft.net> writes:
> > Because I've seen gcc optimize this properly before (at least on
> > sparc64), it means that either:
> >
> > 1) There is a GCC bug where the properties of the constants
> >    do not propagate.
> >
> > 2) GCC really thinks the divide is cheaper (code density vs.
> >    cycle count tradeoffs etc.)
>
> Probably Eric compiled with the now default
> CONFIG_CC_OPTIMIZE_FOR_SIZE/-Os. With that gcc decides to use the shorter
> hardware divide instruction, even though it is significantly slower than an
> expanded optimized sequence for constant dividend.
>
> We've seen this in a few other cases while during performance regression
> testing between kernels that still used -O2 vs the newer -Os.
>
> No good solution found unfortunately.

Well, this could explain but unfortunatly I dont have this option set :

# grep OPTIMIZE .config
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set

# gcc -v
Using built-in specs.
Target: x86_64-unknown-linux-gnu
Configured with: ../gcc-4.1.1/configure --enable-languages=c,c++
Thread model: posix
gcc version 4.1.1

Then I did :

# make drivers/net/tg3.s
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CC      drivers/net/tg3.s

# more drivers/net/tg3.s
        .file   "tg3.c"
# GNU C version 4.1.1 (x86_64-unknown-linux-gnu)
#       compiled by GNU C version 4.1.0.
# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  -nostdinc -Iinclude -D__KERNEL__ -DCONFIG_AS_CFI=1
# -DKBUILD_STR(s)=#s -DKBUILD_BASENAME=KBUILD_STR(tg3)
# -DKBUILD_MODNAME=KBUILD_STR(tg3) -isystem -include -MD -march=k8 -m64
# -mno-red-zone -mcmodel=kernel -mno-sse -mno-mmx -mno-sse2 -mno-3dnow
# -maccumulate-outgoing-args -auxbase-strip -O2 -Wall -Wundef
# -Wstrict-prototypes -Wno-trigraphs -Wno-sign-compare
# -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-aliasing
# -fno-common -fno-reorder-blocks -fno-asynchronous-unwind-tables
# -funit-at-a-time -fno-omit-frame-pointer -fno-optimize-sibling-calls
# -fno-stack-protector -fverbose-asm
# options enabled:  -falign-loops -fargument-alias -fbranch-count-reg
# -fcaller-saves -fcprop-registers -fcrossjumping -fcse-follow-jumps
# -fcse-skip-blocks -fdefer-pop -fdelete-null-pointer-checks
# -fearly-inlining -feliminate-unused-debug-types -fexpensive-optimizations
# -ffunction-cse -fgcse -fgcse-lm -fguess-branch-probability -fident
# -fif-conversion -fif-conversion2 -finline-functions-called-once
# -fipa-pure-const -fipa-reference -fipa-type-escape -fivopts
# -fkeep-static-consts -fleading-underscore -floop-optimize
# -floop-optimize2 -fmath-errno -fmerge-constants -foptimize-register-move
# -fpeephole -fpeephole2 -freg-struct-return -fregmove -freorder-functions
# -frerun-cse-after-loop -frerun-loop-opt -fsched-interblock -fsched-spec
# -fsched-stalled-insns-dep -fschedule-insns2 -fshow-column
# -fsplit-ivs-in-unroller -fstrength-reduce -fthread-jumps -ftrapping-math
# -ftree-ccp -ftree-ch -ftree-copy-prop -ftree-copyrename -ftree-dce
# -ftree-dominator-opts -ftree-dse -ftree-fre -ftree-loop-im
# -ftree-loop-ivcanon -ftree-loop-optimize -ftree-lrs -ftree-pre
# -ftree-salias -ftree-sink -ftree-sra -ftree-store-ccp
# -ftree-store-copy-prop -ftree-ter -ftree-vect-loop-version -ftree-vrp
# -funit-at-a-time -fverbose-asm -fzero-initialized-in-bss
# -m128bit-long-double -m64 -m80387 -maccumulate-outgoing-args
# -malign-stringops -mfancy-math-387 -mfp-ret-in-387 -mieee-fp
# -mno-red-zone -mpush-args -mtls-direct-seg-refs

# Compiler executable checksum: a068cb1f6a9c2e4d8616444230e91dfc


Eric
