From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Thu, 2 Mar 2017 07:49:20 +0200
Message-ID: <20170302074920-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: osandov@fb.com, kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, hch@lst.de
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The following changes since commit c470abd4fde40ea6a0846a2beab642a578c0b8cd:

  Linux 4.10 (2017-02-19 14:34:00 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to c4baad50297d84bde1a7ad45e50c73adae4a2192:

  virtio-console: avoid DMA from stack (2017-03-02 01:35:06 +0200)

----------------------------------------------------------------
virtio, vhost: optimizations, fixes

Looks like a quiet cycle for vhost/virtio, just a couple of minor
tweaks. Most notable is automatic interrupt affinity for blk and scsi.
Hopefully other devices are not far behind.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Christoph Hellwig (9):
      virtio_pci: remove struct virtio_pci_vq_info
      virtio_pci: use shared interrupts for virtqueues
      virtio_pci: don't duplicate the msix_enable flag in struct pci_dev
      virtio_pci: simplify MSI-X setup
      virtio: allow drivers to request IRQ affinity when creating VQs
      virtio: provide a method to get the IRQ affinity mask for a virtqueue
      blk-mq: provide a default queue mapping for virtio device
      virtio_blk: use virtio IRQ affinity
      virtio_scsi: use virtio IRQ affinity

Jason Wang (2):
      vhost: try avoiding avail index access when getting descriptor
      vhost: introduce O(1) vq metadata cache

Michael S. Tsirkin (1):
      virtio_mmio: expose header to userspace

Omar Sandoval (1):
      virtio-console: avoid DMA from stack

 block/Kconfig                              |   5 +
 block/Makefile                             |   1 +
 block/blk-mq-virtio.c                      |  54 +++++
 drivers/block/virtio_blk.c                 |  14 +-
 drivers/char/virtio_console.c              |  14 +-
 drivers/crypto/virtio/virtio_crypto_core.c |   2 +-
 drivers/gpu/drm/virtio/virtgpu_kms.c       |   2 +-
 drivers/misc/mic/vop/vop_main.c            |   2 +-
 drivers/net/caif/caif_virtio.c             |   3 +-
 drivers/net/virtio_net.c                   |   2 +-
 drivers/remoteproc/remoteproc_virtio.c     |   3 +-
 drivers/rpmsg/virtio_rpmsg_bus.c           |   2 +-
 drivers/s390/virtio/kvm_virtio.c           |   3 +-
 drivers/s390/virtio/virtio_ccw.c           |   3 +-
 drivers/scsi/virtio_scsi.c                 | 127 +---------
 drivers/vhost/vhost.c                      | 173 +++++++++----
 drivers/vhost/vhost.h                      |   8 +
 drivers/virtio/virtio_balloon.c            |   3 +-
 drivers/virtio/virtio_input.c              |   3 +-
 drivers/virtio/virtio_mmio.c               |   5 +-
 drivers/virtio/virtio_pci_common.c         | 376 ++++++++++++-----------------
 drivers/virtio/virtio_pci_common.h         |  50 +---
 drivers/virtio/virtio_pci_legacy.c         |   9 +-
 drivers/virtio/virtio_pci_modern.c         |  17 +-
 include/linux/blk-mq-virtio.h              |  10 +
 include/linux/cpuhotplug.h                 |   1 -
 include/linux/virtio_config.h              |  12 +-
 include/uapi/linux/Kbuild                  |   1 +
 include/{ => uapi}/linux/virtio_mmio.h     |   0
 include/uapi/linux/virtio_pci.h            |   2 +-
 net/vmw_vsock/virtio_transport.c           |   3 +-
 31 files changed, 456 insertions(+), 454 deletions(-)
 create mode 100644 block/blk-mq-virtio.c
 create mode 100644 include/linux/blk-mq-virtio.h
 rename include/{ => uapi}/linux/virtio_mmio.h (100%)
