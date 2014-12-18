From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Thu, 18 Dec 2014 12:46:05 +0200
Message-ID: <20141218104605.GA3912@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
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

The following changes since commit f01a2a811ae04124fc9382925038fcbbd2f0b7c8:

  virtio_ccw: finalize_features error handling (2014-12-09 21:42:06 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 5ff16110c637726111662c1df41afd9df7ef36bd:

  virtio_pci: restore module attributes (2014-12-17 00:59:40 +0200)

----------------------------------------------------------------
vhost/virtio: virtio 1.0 related fixes

Most importantly, this fixes using virtio_pci as a module.

Further, the big virtio 1.0 conversion missed a couple of places. This fixes
them up.

This isn't 100% sparse-clean yet because on many architectures get_user
triggers sparse warnings when used with __bitwise tag (when same tag is on both
pointer and value read).

I posted a patchset to fix it up by adding __force on all
arches that don't already have it (many do), when that's
merged these warnings will go away.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Herbert Xu (1):
      virtio_pci: restore module attributes

Michael S. Tsirkin (15):
      virtio: set VIRTIO_CONFIG_S_FEATURES_OK on restore
      virtio_config: fix virtio_cread_bytes
      virtio_pci_common.h: drop VIRTIO_PCI_NO_LEGACY
      virtio_pci: move probe to common file
      virtio_pci: add VIRTIO_PCI_NO_LEGACY
      virtio: core support for config generation
      tools/virtio: more stubs
      tools/virtio: fix vringh test
      tools/virtio: 64 bit features
      tools/virtio: enable -Werror
      tools/virtio: add virtio 1.0 in virtio_test
      tools/virtio: add virtio 1.0 in vringh_test
      vringh: 64 bit features
      vringh: update for virtio 1.0 APIs
      mic/host: fix up virtio 1.0 APIs

 drivers/virtio/virtio_pci_common.h     |   7 +-
 include/linux/virtio_config.h          |  29 +++++++-
 include/linux/vringh.h                 |  37 +++++++++-
 include/uapi/linux/virtio_pci.h        |  15 ++--
 tools/virtio/linux/virtio.h            |   1 +
 tools/virtio/linux/virtio_byteorder.h  |   8 +++
 tools/virtio/linux/virtio_config.h     |  70 +++++++++++++++++-
 tools/virtio/uapi/linux/virtio_types.h |   1 +
 drivers/misc/mic/host/mic_debugfs.c    |  18 +++--
 drivers/vhost/vringh.c                 | 125 ++++++++++++++++++++-------------
 drivers/virtio/virtio.c                |  37 ++++++----
 drivers/virtio/virtio_pci_common.c     |  39 +++++++++-
 drivers/virtio/virtio_pci_legacy.c     |  24 +------
 tools/virtio/virtio_test.c             |  15 +++-
 tools/virtio/vringh_test.c             |   5 +-
 tools/virtio/Makefile                  |   2 +-
 16 files changed, 324 insertions(+), 109 deletions(-)
 create mode 100644 tools/virtio/linux/virtio_byteorder.h
 create mode 100644 tools/virtio/uapi/linux/virtio_types.h
