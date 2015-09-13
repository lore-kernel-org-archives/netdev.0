From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 00/39] drop null test before destroy functions
Date: Sun, 13 Sep 2015 14:14:53 +0200
Message-ID: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, HPDD-discuss-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	Carolyn Wyborny <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Matthew Vick <matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mitch Williams <mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chao Yu <chao2.yu-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shannon Nelson <shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TaqPxH82wqD4g@public.gmane.org
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Recent commits to kernel/git/torvalds/linux.git have made the following
functions able to tolerate NULL arguments:

kmem_cache_destroy (commit 3942d29918522)
mempool_destroy (commit 4e3ca3e033d1)
dma_pool_destroy (commit 44d7175da6ea)

These patches remove the associated NULL tests for the files that I found
easy to compile test.  If these changes are OK, I will address the
remainder later.

---

 arch/x86/kvm/mmu.c                                 |    6 --
 block/bio-integrity.c                              |    7 --
 block/bio.c                                        |    7 --
 block/blk-core.c                                   |    3 -
 block/elevator.c                                   |    3 -
 drivers/atm/he.c                                   |    7 --
 drivers/block/aoe/aoedev.c                         |    3 -
 drivers/block/drbd/drbd_main.c                     |   21 ++-----
 drivers/block/pktcdvd.c                            |    3 -
 drivers/block/rbd.c                                |    6 --
 drivers/dma/dmaengine.c                            |    6 --
 drivers/firmware/google/gsmi.c                     |    3 -
 drivers/gpu/drm/i915/i915_dma.c                    |   19 ++----
 drivers/iommu/amd_iommu_init.c                     |    7 --
 drivers/md/bcache/bset.c                           |    3 -
 drivers/md/bcache/request.c                        |    3 -
 drivers/md/bcache/super.c                          |    9 +--
 drivers/md/dm-bufio.c                              |    3 -
 drivers/md/dm-cache-target.c                       |    3 -
 drivers/md/dm-crypt.c                              |    6 --
 drivers/md/dm-io.c                                 |    3 -
 drivers/md/dm-log-userspace-base.c                 |    3 -
 drivers/md/dm-region-hash.c                        |    4 -
 drivers/md/dm.c                                    |   13 +---
 drivers/md/multipath.c                             |    3 -
 drivers/md/raid1.c                                 |    6 --
 drivers/md/raid10.c                                |    9 +--
 drivers/md/raid5.c                                 |    3 -
 drivers/mtd/nand/nandsim.c                         |    3 -
 drivers/mtd/ubi/attach.c                           |    4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    3 -
 drivers/staging/lustre/lustre/llite/super25.c      |   16 +----
 drivers/staging/lustre/lustre/obdclass/genops.c    |   24 ++------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    6 --
 drivers/staging/rdma/hfi1/user_sdma.c              |    3 -
 drivers/thunderbolt/ctl.c                          |    3 -
 drivers/usb/gadget/udc/bdc/bdc_core.c              |    3 -
 drivers/usb/gadget/udc/gr_udc.c                    |    3 -
 drivers/usb/gadget/udc/mv_u3d_core.c               |    3 -
 drivers/usb/gadget/udc/mv_udc_core.c               |    3 -
 drivers/usb/host/fotg210-hcd.c                     |   12 +---
 drivers/usb/host/fusbh200-hcd.c                    |   12 +---
 drivers/usb/host/whci/init.c                       |    3 -
 drivers/usb/host/xhci-mem.c                        |   12 +---
 fs/btrfs/backref.c                                 |    3 -
 fs/btrfs/delayed-inode.c                           |    3 -
 fs/btrfs/delayed-ref.c                             |   12 +---
 fs/btrfs/disk-io.c                                 |    3 -
 fs/btrfs/extent_io.c                               |    6 --
 fs/btrfs/extent_map.c                              |    3 -
 fs/btrfs/file.c                                    |    3 -
 fs/btrfs/inode.c                                   |   18 ++----
 fs/btrfs/ordered-data.c                            |    3 -
 fs/dlm/memory.c                                    |    6 --
 fs/ecryptfs/main.c                                 |    3 -
 fs/ext4/crypto.c                                   |    9 +--
 fs/ext4/extents_status.c                           |    3 -
 fs/ext4/mballoc.c                                  |    3 -
 fs/f2fs/crypto.c                                   |    9 +--
 fs/gfs2/main.c                                     |   29 ++--------
 fs/jbd2/journal.c                                  |   15 +----
 fs/jbd2/revoke.c                                   |   12 +---
 fs/jbd2/transaction.c                              |    6 --
 fs/jffs2/malloc.c                                  |   27 +++------
 fs/nfsd/nfscache.c                                 |    6 --
 fs/nilfs2/super.c                                  |   12 +---
 fs/ocfs2/dlm/dlmlock.c                             |    3 -
 fs/ocfs2/dlm/dlmmaster.c                           |   16 +----
 fs/ocfs2/super.c                                   |   18 ++----
 fs/ocfs2/uptodate.c                                |    3 -
 lib/debugobjects.c                                 |    3 -
 net/core/sock.c                                    |   12 +---
 net/dccp/ackvec.c                                  |   12 +---
 net/dccp/ccid.c                                    |    3 -
 net/sunrpc/sched.c                                 |   12 +---
 75 files changed, 180 insertions(+), 381 deletions(-)
