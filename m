From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 0/4] page_pool proof-of-concept early code
Date: Tue, 20 Dec 2016 14:28:07 +0100
Message-ID: <20161220132444.18788.50875.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This is an RFC patchset of my *work-in-progress* page_pool implemenation.
This is NOT ready for inclusion.  People asked to see the code, so here we go.

This patchset is focused providing a generic replacement for the
driver page recycle caches. Where mlx5 is the first user in patch-3.

Notice that patch-2 is more "MM-invasive" (modifies put_page) than
patch-4 which is less MM-agressive (scaled back based on input from
Mel Gorman).

I do know that all page-flags are used (for 32bit), thus I'm open to
suggestions/ideas on howto work-around this (need some way to identify
a page belongs to a page pool).


This patchset is the bare-minimum PoC that allows me to benchmarks
these ideas and see if performance is going in the right direction.
It is not safe, e.g. unloading the driver can crash the kernel.

---

Jesper Dangaard Brouer (4):
      doc: page_pool introduction documentation
      page_pool: basic implementation of page_pool
      mlx5: use page_pool
      page_pool: change refcnt model


 Documentation/vm/page_pool/introduction.rst       |   71 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   28 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   47 ++
 include/linux/mm.h                                |    1 
 include/linux/mm_types.h                          |   11 +
 include/linux/page-flags.h                        |   13 +
 include/linux/page_pool.h                         |  168 +++++++++
 include/linux/skbuff.h                            |    2 
 include/trace/events/mmflags.h                    |    3 
 mm/Makefile                                       |    3 
 mm/page_alloc.c                                   |    6 
 mm/page_pool.c                                    |  402 +++++++++++++++++++++
 mm/slub.c                                         |    4 
 mm/swap.c                                         |    3 
 15 files changed, 741 insertions(+), 22 deletions(-)
 create mode 100644 Documentation/vm/page_pool/introduction.rst
 create mode 100644 include/linux/page_pool.h
 create mode 100644 mm/page_pool.c

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
