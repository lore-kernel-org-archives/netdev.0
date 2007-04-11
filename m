From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: link error : 2.6.21-rc6-mm1 for s390
Date: Tue, 10 Apr 2007 18:29:37 -0700
Message-ID: <20070410182937.8169c672.akpm@linux-foundation.org>
References: <20070411005616.GG15262@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965908AbXDKBaR@vger.kernel.org>
In-Reply-To: <20070411005616.GG15262@Krystal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007 20:56:16 -0400
Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> The last for today : link error of 2.6.21-rc6-mm1 for s390 :
> 
> 
>   /opt/crosstool/gcc-4.1.1-glibc-2.3.6/s390-unknown-linux-gnu/bin/s390-unknown-linux-gnu-ld -m elf_s390 -e start -o .tmp_vmlinux1 -T arch/s390/kernel/vmlinux.lds arch/s390/kernel/head.o arch/s390/kernel/init_task.o  init/built-in.o --start-group  usr/built-in.o  arch/s390/mm/built-in.o  arch/s390/kernel/built-in.o  arch/s390/crypto/built-in.o  arch/s390/appldata/built-in.o  arch/s390/hypfs/built-in.o  kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o  block/built-in.o  ltt/built-in.o  lib/lib.a  arch/s390/lib/lib.a  lib/built-in.o  arch/s390/lib/built-in.o  drivers/built-in.o  sound/built-in.o  drivers/s390/built-in.o  arch/s390/math-emu/built-in.o  net/built-in.o --end-group
> lib/built-in.o: In function `__div64_32':
> : multiple definition of `__div64_32'
> arch/s390/lib/lib.a(div64.o):div64.c:(.text+0x0): first defined here
> /opt/crosstool/gcc-4.1.1-glibc-2.3.6/s390-unknown-linux-gnu/bin/s390-unknown-linux-gnu-ld: Warning: size of symbol `__div64_32' changed from 218 in arch/s390/lib/lib.a(div64.o) to 260 in lib/built-in.o

git-net.patch implements generic lib/div64.c, but s390 also has a private one.

Presumably the appropriate fix is to remove s390's private implementation within
davem's tree.
