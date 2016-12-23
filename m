From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net/mm PATCH v2 0/3] Page fragment updates
Date: Fri, 23 Dec 2016 09:16:39 -0800
Message-ID: <20161223170756.14573.74139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series takes care of a few cleanups for the page fragments API.

First we do some renames so that things are much more consistent.  First we
move the page_frag_ portion of the name to the front of the functions
names.  Secondly we split out the cache specific functions from the other
page fragment functions by adding the word "cache" to the name.

Second I did some minor clean-up on the function calls so that they are
more inline with the existing __free_pages calls in terms of how they
operate.

Finally I added a bit of documentation that will hopefully help to explain
some of this.  I plan to revisit this later as we get things more ironed
out in the near future with the changes planned for the DMA setup to
support eXpress Data Path.

---

v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages

I'm listing this as a patch for net or mm since I had originally submitted
it against mm as that was where the patches for the __page_frag functions
has previously resided.  However they are now also in net, and I wanted to
get this fixed before the merge window closed as I was hoping to make use
of these APIs in net-next and I already have about 20 patches that are
waiting on these patches to be accepted.

I tried to get in touch with Andrew about this fix but I haven't heard any
reply to the email I sent out on Tuesday.  The last comment I had from
Andrew against v1 was "Looks good to me.  I have it all queued for post-4.9
processing.", but I haven't received any notice they were applied.

Alexander Duyck (3):
      mm: Rename __alloc_page_frag to page_frag_alloc and __free_page_frag to page_frag_free
      mm: Rename __page_frag functions to __page_frag_cache, drop order from drain
      mm: Add documentation for page fragment APIs


 Documentation/vm/page_frags               |   42 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c |    6 ++--
 include/linux/gfp.h                       |    9 +++---
 include/linux/skbuff.h                    |    2 +
 mm/page_alloc.c                           |   33 +++++++++++++----------
 net/core/skbuff.c                         |    8 +++---
 6 files changed, 73 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/vm/page_frags

--
