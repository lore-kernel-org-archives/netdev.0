From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 00/12] radix-tree: split out struct radix_tree_root out to <linux/radix-tree-root.h>
Date: Mon,  9 Oct 2017 01:10:01 +0900
Message-ID: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
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
        Yishai Hadas <yishaih@mella
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The motivation of this series is to cut down unnecessary header
dependency in terms of radix tree.

Sub-systems or drivers that use radix-tree for data management
typically embed struct radix_tree_root in their data structures,
like this:

struct foo {
       ...

       struct radix_tree_root   foo_tree;
       ...
};

So, <linux/foo.h> needs to include <linux/radix-tree.h>,
therefore, users of <linux/foo.h> include a lot of bloat
from <linux/radix-tree.h>.

If you see the definition of radix_tree_root,

   struct radix_tree_root {
           gfp_t			gfp_mask;
	   struct radix_tree_node	__rcu *rnode;
   };

it is a very simple structure.
It only depends on <linux/types.h> for gfp_t and
<linux/compiler.h> for __rcu.

By splitting out the radix_tree_root definition,
we can reduce the header file dependency.

Reducing the header dependency will help for speeding the kernel
build, suppressing unnecessary recompile of objects during
git-bisect'ing, etc.

The patch 1 is a trivial clean-up; it is just here
to avoid conflict.

The patch 2 is the main part of this series;
split out struct radix_tree_root.

The rest of the series replace <linux/radix-tree.h>
with <linux/radix-tree-root.h> where appropriate.

Please review if the idea is OK.

If it is OK, I'd like to know how to apply the series.

Perhaps, the first two for v4.15.  Then, rest of series
will be sent per-subsystem for v4.16?

Or, can somebody take care of the whole series?

I checked allmodconfig for x86 and arm64.
I am expecting 0 day testing will check it too.



Masahiro Yamada (12):
  radix-tree: replace <linux/spinlock.h> with <linux/spinlock_types.h>
  radix-tree: split struct radix_tree_root to <linux/radix-tree-root.h>
  irqdomain: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  writeback: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  iocontext.h: replace <linux/radix-tree.h> with
    <linux/radix-tree-root.h>
  fs: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  blkcg: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  fscache: include <linux-radix-tree.h>
  sh: intc: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  net/mlx5: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
  drm/i915: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>

 drivers/gpu/drm/i915/i915_gem.c            |  1 +
 drivers/gpu/drm/i915/i915_gem_context.c    |  1 +
 drivers/gpu/drm/i915/i915_gem_context.h    |  2 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |  1 +
 drivers/gpu/drm/i915/i915_gem_object.h     |  1 +
 drivers/net/ethernet/mellanox/mlx4/cq.c    |  1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |  2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c    |  1 +
 drivers/net/ethernet/mellanox/mlx4/srq.c   |  1 +
 drivers/sh/intc/internals.h                |  2 +-
 include/linux/backing-dev-defs.h           |  2 +-
 include/linux/blk-cgroup.h                 |  2 +-
 include/linux/fs.h                         |  2 +-
 include/linux/fscache.h                    |  1 +
 include/linux/iocontext.h                  |  2 +-
 include/linux/irqdomain.h                  |  2 +-
 include/linux/mlx4/device.h                |  2 +-
 include/linux/mlx4/qp.h                    |  1 +
 include/linux/mlx5/driver.h                |  2 +-
 include/linux/mlx5/qp.h                    |  1 +
 include/linux/radix-tree-root.h            | 24 ++++++++++++++++++++++++
 include/linux/radix-tree.h                 |  8 ++------
 22 files changed, 46 insertions(+), 16 deletions(-)
 create mode 100644 include/linux/radix-tree-root.h

-- 
2.7.4
