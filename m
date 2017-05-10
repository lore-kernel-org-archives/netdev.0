From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio: fixes, cleanups, performance
Date: Wed, 10 May 2017 15:24:07 +0300
Message-ID: <20170510152407-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        borntraeger@de.ibm.com, colin.king@canonical.com,
        cornelia.huck@de.ibm.com, dan.carpenter@oracle.com,
        jasowang@redhat.com, mst@redhat.com, nsekhar@ti.com,
        pasic@linux.vnet.ibm.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit a351e9b9fc24e982ec2f0e76379a49826036da12:

  Linux 4.11 (2017-04-30 19:47:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to c8b0d7290657996a29f318b948d2397d30e70c36:

  s390/virtio: change maintainership (2017-05-09 16:43:25 +0300)

----------------------------------------------------------------
virtio: fixes, cleanups, performance

A bunch of changes to virtio, most affecting virtio net.
ptr_ring batched zeroing - first of batching enhancements
that seems ready.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Christian Borntraeger (1):
      s390/virtio: change maintainership

Colin Ian King (1):
      tools/virtio: fix spelling mistake: "wakeus" -> "wakeups"

Cornelia Huck (1):
      virtio: virtio_driver doc

Dan Carpenter (2):
      ringtest: fix an assert statement
      virtio_net: tidy a couple debug statements

Michael S. Tsirkin (11):
      virtio: wrap find_vqs
      virtio: add context flag to find vqs
      virtio: allow extra context per descriptor
      virtio_net: allow specifying context for rx
      virtio_net: rework mergeable buffer handling
      virtio_net: reduce alignment for buffers
      virtio_net: fix support for small rings
      virtio_net: don't reset twice on XDP on/off
      ptr_ring: batch ring zeroing
      ringtest: support test specific parameters
      ptr_ring: support testing different batching sizes

Sekhar Nori (1):
      tools/virtio: fix build breakage

 MAINTAINERS                                |   2 +-
 drivers/block/virtio_blk.c                 |   3 +-
 drivers/char/virtio_console.c              |   6 +-
 drivers/crypto/virtio/virtio_crypto_core.c |   3 +-
 drivers/gpu/drm/virtio/virtgpu_kms.c       |   3 +-
 drivers/misc/mic/vop/vop_main.c            |   9 +-
 drivers/net/caif/caif_virtio.c             |   3 +-
 drivers/net/virtio_net.c                   | 147 ++++++++++++++++-------------
 drivers/remoteproc/remoteproc_virtio.c     |  10 +-
 drivers/rpmsg/virtio_rpmsg_bus.c           |   2 +-
 drivers/s390/virtio/kvm_virtio.c           |   8 +-
 drivers/s390/virtio/virtio_ccw.c           |   7 +-
 drivers/scsi/virtio_scsi.c                 |   3 +-
 drivers/virtio/virtio_balloon.c            |   3 +-
 drivers/virtio/virtio_input.c              |   3 +-
 drivers/virtio/virtio_mmio.c               |   8 +-
 drivers/virtio/virtio_pci_common.c         |  17 ++--
 drivers/virtio/virtio_pci_common.h         |   4 +-
 drivers/virtio/virtio_pci_legacy.c         |   4 +-
 drivers/virtio/virtio_pci_modern.c         |  12 ++-
 drivers/virtio/virtio_ring.c               |  77 ++++++++++++---
 include/linux/ptr_ring.h                   |  63 +++++++++++--
 include/linux/virtio.h                     |  13 +++
 include/linux/virtio_config.h              |  25 ++++-
 include/linux/virtio_ring.h                |   3 +
 net/vmw_vsock/virtio_transport.c           |   6 +-
 tools/virtio/linux/virtio.h                |   1 +
 tools/virtio/ringtest/main.c               |  15 ++-
 tools/virtio/ringtest/main.h               |   2 +
 tools/virtio/ringtest/ptr_ring.c           |   3 +
 tools/virtio/virtio_test.c                 |   4 +-
 tools/virtio/vringh_test.c                 |   7 +-
 32 files changed, 330 insertions(+), 146 deletions(-)
