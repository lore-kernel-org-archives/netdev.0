From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: new features for 4.8
Date: Wed, 3 Aug 2016 17:14:42 +0300
Message-ID: <20160803171442-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, kneumoin@virtuozzo.com,
	linux-kernel@vger.kernel.org, imbrenda@linux.vnet.ibm.com,
	stefanha@redhat.com, den@openvz.org,
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

I already have more bugfixes on top queued, but not regression
fixes so it does not seem worth it to delay this anymore.

The following changes since commit 523d939ef98fd712632d93a5a2b588e477a7565e:

  Linux 4.7 (2016-07-24 12:23:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to b226acab2f6aaa45c2af27279b63f622b23a44bd:

  VSOCK: Use kvfree() (2016-08-02 16:56:08 +0300)

----------------------------------------------------------------
virtio/vhost: new features for 4.8

- New vsock device support in host and guest
- Platform IOMMU support in host and guest,
  including compatibility quirks for legacy systems.
- Misc fixes and cleanups.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Asias He (4):
      VSOCK: Introduce virtio_vsock_common.ko
      VSOCK: Introduce virtio_transport.ko
      VSOCK: Introduce vhost_vsock.ko
      VSOCK: Add Makefile and Kconfig

Jason Wang (5):
      vhost: simplify work flushing
      vhost: lockless enqueuing
      vhost: introduce vhost memory accessors
      vhost: convert pre sorted vhost memory array to interval tree
      vhost: new device IOTLB API

Konstantin Neumoin (1):
      balloon: check the number of available pages in leak balloon

Michael S. Tsirkin (6):
      virtio: new feature to detect IOMMU device quirk
      vop: pull in vhost Kconfig
      vhost: drop vringh dependency
      vhost: drop vringh dependency
      vhost: detect 32 bit integer wrap around
      vhost: split out vringh Kconfig

Stefan Hajnoczi (2):
      VSOCK: transport-specific vsock_transport functions
      VSOCK: defer sock removal to transports

Wei Yongjun (1):
      VSOCK: Use kvfree()

 drivers/vhost/vhost.h                              |  64 +-
 include/linux/virtio_config.h                      |  13 +
 include/linux/virtio_vsock.h                       | 154 ++++
 include/net/af_vsock.h                             |   6 +
 .../trace/events/vsock_virtio_transport_common.h   | 144 +++
 include/uapi/linux/vhost.h                         |  33 +
 include/uapi/linux/virtio_config.h                 |  10 +-
 include/uapi/linux/virtio_ids.h                    |   1 +
 include/uapi/linux/virtio_vsock.h                  |  94 ++
 drivers/vhost/net.c                                |  67 +-
 drivers/vhost/vhost.c                              | 927 +++++++++++++++----
 drivers/vhost/vsock.c                              | 719 +++++++++++++++
 drivers/virtio/virtio_balloon.c                    |   2 +
 drivers/virtio/virtio_ring.c                       |  15 +-
 net/vmw_vsock/af_vsock.c                           |  25 +-
 net/vmw_vsock/virtio_transport.c                   | 624 +++++++++++++
 net/vmw_vsock/virtio_transport_common.c            | 992 +++++++++++++++++++++
 net/vmw_vsock/vmci_transport.c                     |   2 +
 MAINTAINERS                                        |  13 +
 drivers/Makefile                                   |   1 +
 drivers/misc/mic/Kconfig                           |   4 +
 drivers/net/caif/Kconfig                           |   2 +-
 drivers/vhost/Kconfig                              |  18 +-
 drivers/vhost/Kconfig.vringh                       |   5 +
 drivers/vhost/Makefile                             |   4 +
 include/uapi/linux/Kbuild                          |   1 +
 net/vmw_vsock/Kconfig                              |  20 +
 net/vmw_vsock/Makefile                             |   6 +
 28 files changed, 3765 insertions(+), 201 deletions(-)
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/trace/events/vsock_virtio_transport_common.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c
 create mode 100644 drivers/vhost/Kconfig.vringh
