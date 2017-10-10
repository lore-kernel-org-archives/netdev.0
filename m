From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out
 to <linux/radix-tree-root.h>
Date: Tue, 10 Oct 2017 05:18:30 -0700
Message-ID: <20171010121829.GA26493@bombadil.infradead.org>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-cachefs@redhat.com, linux-sh@vger.kernel.org,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
        linux-rdma@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rich Felker <dalias@libc.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        intel-gfx@lists.freedesktop.org,
        Yishai Hadas <yishaih@mellanox.com>,
        Joonas La
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 01:10:01AM +0900, Masahiro Yamada wrote:
> Reducing the header dependency will help for speeding the kernel
> build, suppressing unnecessary recompile of objects during
> git-bisect'ing, etc.

Well, does it?  You could provide measurements showing before/after
time to compile, or time to recompile after touching a header file that
is included by radix-tree.h and not by radix-tree-root.h.

Look at the files included (never mind the transitively included files):

#include <linux/bitops.h>
#include <linux/bug.h>
#include <linux/kernel.h>
#include <linux/list.h>
#include <linux/preempt.h>
#include <linux/rcupdate.h>
#include <linux/spinlock.h>
#include <linux/types.h>

These are not exactly rare files to be included.  My guess is that most
of the files in the kernel end up depending on these files *anyway*, either
directly or through some path that isn't the radix tree.
