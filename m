From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 20 Feb 2017 12:22:27 +1100
Message-ID: <20170220122227.54f04c2a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Masami Hiramatsu <mhiramat@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  kernel/extable.c

between commit:

  74451e66d516 ("bpf: make jited programs visible in traces")

from the net-next tree and commit:

  5b485629ba0d ("kprobes, extable: Identify kprobes trampolines as kernel text area")

from the tip tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc kernel/extable.c
index bd82117ad424,e1359474baa5..000000000000
--- a/kernel/extable.c
+++ b/kernel/extable.c
@@@ -20,7 -20,7 +20,8 @@@
  #include <linux/module.h>
  #include <linux/mutex.h>
  #include <linux/init.h>
 +#include <linux/filter.h>
+ #include <linux/kprobes.h>
  
  #include <asm/sections.h>
  #include <linux/uaccess.h>
@@@ -105,8 -105,8 +106,10 @@@ int __kernel_text_address(unsigned lon
  		return 1;
  	if (is_ftrace_trampoline(addr))
  		return 1;
 +	if (is_bpf_text_address(addr))
 +		return 1;
+ 	if (is_kprobe_optinsn_slot(addr) || is_kprobe_insn_slot(addr))
+ 		return 1;
  	/*
  	 * There might be init symbols in saved stacktraces.
  	 * Give those symbols a chance to be printed in
@@@ -128,8 -128,8 +131,10 @@@ int kernel_text_address(unsigned long a
  		return 1;
  	if (is_ftrace_trampoline(addr))
  		return 1;
 +	if (is_bpf_text_address(addr))
 +		return 1;
+ 	if (is_kprobe_optinsn_slot(addr) || is_kprobe_insn_slot(addr))
+ 		return 1;
  	return 0;
  }
  
