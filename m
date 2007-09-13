From: Roland Dreier <rdreier@cisco.com>
Subject: InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 10:57:27 -0700
Message-ID: <adahclymos8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:29460 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbXIMR5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 13:57:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 2.6.24 probably opening in the not-too-distant future, it's
probably a good time to review what my plans are for when the merge
window opens.

At the kernel summit, we discussed patch review (doing a web search
for "kernel summit" "reviewed-by:" should turn up lots of info on
this).  Due to an unfortunate combination of vacation and conference
travel, summer colds, and other inconveniences, I am very backed up on
reviewing.  And in any case, I've allowed too much code review to be
dumped on me -- when there are dozens of people working on IB and RDMA
stuff, it obviously doesn't work to expect me to do all the reviewing.

Unfortunately, due to the length of the backlog and the fact that
2.6.23 seems fairly close, some of the things listed below are going
to miss the 2.6.24 merge window.  So, although the plan is to phase in
requiring "Reviewed-by:" gently, for this merge, if you can get
someone other than me to review your work, then the chances of it
being merged increase dramatically.  I'm talking about a real review--
ideally, someone independent (from another company would be good) who
is willing to provide a "Reviewed-by:" line that means the reviewer
has really looked at and thought about the patch.  There should be a
mailing list thread you can point me at where the reviewer comments on
the patch and a new version of that patch addressing all comments is
posted (or in exceptional cases, where the patch is perfect to start
with, where the reviewer says the patch is great).

For example, given the number of IPoIB changes pending, it might be a
good idea for the people submitting them to get together and trade
reviews (ie "If you review my patch, I'll review your patch").  There
are a few cases where getting a review may not be necessary.  First of
all, trivial and obvious patches don't need a review.  It's a
judgement call what is trivial or obvious, and it's always a good idea
to provide a changelog that makes it clear why a patch is trivial and
obviously correct.  Second, hardware driver patches may not make sense
to anyone outside of the company whose hardware the driver is for.
Still, in this case, an internal Reviewed-by: would be nice, and also
a changelog that explains the reason for the change always helps
(don't just tell me what your patch does, but also explain what the
patch fixes and what the impact of the current situation is).

Anyway, here are all the pending things that I'm aware of.  As usual,
if something isn't already in my tree and isn't listed below, I
probably missed it or dropped it by mistake.  Please remind me again
in that case.

Core:

 - My user_mad P_Key index support patch.  I'll test the ioctl to
   change to the new mode and merge this I guess, since Hal and Sean
   have tested this out.

 - A fix to the user_mad 32-bit big-endian userspace 64/32 problem
   with the method_mask when registering agents.  I'll write a patch
   to handle this in a way that doesn't change the ABI for anything
   other than the broken case and hope to get someone to review this
   so it can be merged.

 - Sean's QoS changes.  These look fine at first glance, and I just
   plan to understand the backwards compatibility story (ie how this
   works with an old SM) and merge.  Anyone who objects let me know.

 - Sean's IB CM MRA interface changes.  Don't know at this point.  It
   seems OK but I'm not clear on what if any real-world improvement
   this gives us.

ULPs:

 - Pradeep's IPoIB CM support for devices that don't have SRQs.  I
   think the basic approach makes sense (I don't think faking SRQs at
   some other layer is really feasible) and I need to find time to
   look at the details to see if the current patch looks workable.  I'm
   likely to merge this; getting an independent Reviewed-by: would
   certainly be appreciated too.

 - Moni's IPoIB bonding support.  This seems mostly an issue of
   getting the core bonding maintainer's attention.  However getting a
   Reviewed-by: for the IPoIB changes wouldn't hurt too.

 - Rolf's IPoIB MGID scope changes.  Certainly we want to fix this
   issue but the specific changes need review.

 - Eli and Michael's IPoIB stateless offload (checksum offload, LSO,
   LRO, etc).  It's a big series that makes quite a few core changes.
   I think it needs some careful review and is probably at risk of
   missing this merge window.  Sorting in order of invasiveness so we
   can merge at least some of it (if splitting it makes sense) might
   be a good idea.

HW specific:

 - I already merged patches to enable MSI-X by default for mthca and
   mlx4.  I hope there aren't too many systems that get hosed if a
   MSI-X interrupt is generated.

 - Jack and Michael's mlx4 FMR support.  Will merge I guess, although
   I do hope to have time to address the DMA API abuse that is being
   copied from mthca, so that mlx4 and mthca work in Xen domU.

 - ehca patch queue.  Will merge, pending fixes for the few minor
   issues I commented on.

 - Steve's mthca router mode support.  Would be nice to see a review
   from someone at Mellanox.

 - Arthur's mthca doorbell alignment fixes.  I will experiment with a
   few different approaches and post what I like (and fix mlx4 as
   well).  I hope Arthur can review.

 - Michael's mlx4 WQE shrinking patch.  Not sure yet; I'll reply to
   the latest patch directly.

Here are a few topics that I believe will not be ready in time for the
2.6.24 window and will need to wait for 2.6.25:

 - Multiple CQ event vector support.  I haven't seen any discussions
   about how ULPs or userspace apps should decide which vector to use,
   and hence no progress has been made since we deferred this during
   the 2.6.23 merge window.

 - XRC.  Given the length of the backlog above and the fact that a
   first draft of this code has not been posted yet, I don't see any
   way that we could have something this major ready in time.

Here is the complete list of patches I have in my for-2.6.24 branch
waiting for the merge window so far.  Mostly I haven't merged anything
big out of my backlog, so this is essentially all

Ali Ayoub (1):
      IB/sa: Error handling thinko fix

Anton Blanchard (3):
      IB/fmr_pool: Clean up some error messages in fmr_pool.c
      IB/ehca: Make output clearer by removing some debug messages
      IB/ehca: Export module parameters in sysfs

Dotan Barak (1):
      mlx4_core: Use enum value GO_BIT_TIMEOUT_MSECS

Eli Cohen (2):
      IPoIB: Fix typo to end statement with ';' instead of ','
      IPoIB: Fix error path memory leak

Michael S. Tsirkin (2):
      mlx4_core: Enable MSI-X by default
      IB/mthca: Enable MSI-X by default

Peter Oruba (1):
      IB/mthca: Use PCI-X/PCI-Express read control interfaces

Roland Dreier (6):
      IPoIB: Make sure no receives are handled when stopping device
      IB: find_first_zero_bit() takes unsigned pointer
      mlx4_core: Don't free special QPs in QP number bitmap
      IB/mlx4: Use set_data_seg() in mlx4_ib_post_recv()
      IB/ehca: Include <linux/mutex.h> from ehca_classes.h
      IB/mlx4: Fix up SRQ limit_watermark endianness

Steve Wise (1):
      RDMA/cxgb3: Make the iw_cxgb3 module parameters writable
