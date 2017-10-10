From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out to <linux/radix-tree-root.h>
Date: Tue, 10 Oct 2017 21:56:22 +0900
Message-ID: <CAK7LNAQ_SVA1aYYgjMFqJG5OzjYa1EbNDGdrCAOOen_dABX30g@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com> <20171010121829.GA26493@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-cachefs@redhat.com, linux-sh@vger.kernel.org,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        David Airlie <airlied@linux.ie>, linux-rdma@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rich Felker <dalias@libc.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        intel-gfx@lists.freedesktop.org,
        Yishai
To: Matthew Wilcox <willy@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010121829.GA26493@bombadil.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-10-10 21:18 GMT+09:00 Matthew Wilcox <willy@infradead.org>:
> On Mon, Oct 09, 2017 at 01:10:01AM +0900, Masahiro Yamada wrote:
>> Reducing the header dependency will help for speeding the kernel
>> build, suppressing unnecessary recompile of objects during
>> git-bisect'ing, etc.
>
> Well, does it?  You could provide measurements showing before/after
> time to compile, or time to recompile after touching a header file that
> is included by radix-tree.h and not by radix-tree-root.h.
>
> Look at the files included (never mind the transitively included files):
>
> #include <linux/bitops.h>
> #include <linux/bug.h>
> #include <linux/kernel.h>
> #include <linux/list.h>
> #include <linux/preempt.h>
> #include <linux/rcupdate.h>
> #include <linux/spinlock.h>
> #include <linux/types.h>
>
> These are not exactly rare files to be included.  My guess is that most
> of the files in the kernel end up depending on these files *anyway*, either
> directly or through some path that isn't the radix tree.


Good question.

I tested this series, and I confirmed
the total number of included headers decreased,
but did not decrease as much as I had expected.

The statement "most of the files in the kernel end
up depending on these files" is true.

But, with that excuse,
I do not want to conclude this kind of refactoring is pointless.


For example, how can we explain
commit bc6245e5efd70c41eaf9334b1b5e646745cb0fb3 ?


<linux/bug.h> includes the following three.

#include <asm/bug.h>
#include <linux/compiler.h>
#include <linux/build_bug.h>

Your statement applies to them too.
Actually, I did not see any impact
by replacing <linux/bug.h> in my files with <linux/build_bug.h>



Generally, people do not pay much attention
in decreasing header dependency.

One refactoring alone does not produce much benefits,
but making continuous efforts will disentangle the knotted threads.
Of course, this might be a pipe dream...



-- 
Best Regards
Masahiro Yamada
