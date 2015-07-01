From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio/vhost: cross endian support
Date: Wed, 1 Jul 2015 11:31:50 +0200
Message-ID: <20150701113150-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cornelia.huck@de.ibm.com, gkurz@linux.vnet.ibm.com,
	kraxel@redhat.com, mst@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbbGAJby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 05:31:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 8a7b19d8b542b87bccc3eaaf81dcc90a5ca48aea:

  include/uapi/linux/virtio_balloon.h: include linux/virtio_types.h (2015-06-01 15:46:54 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 59a5b0f7bf74f88da6670bcbf924d8cc1e75b1ee:

  virtio-pci: alloc only resources actually used. (2015-06-24 08:15:09 +0200)

----------------------------------------------------------------
virtio/vhost: cross endian support

I have just queued some more bugfix patches today but none fix regressions and
none are related to these ones, so it looks like a good time for a merge for
-rc1.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Gerd Hoffmann (1):
      virtio-pci: alloc only resources actually used.

Greg Kurz (8):
      virtio: introduce virtio_is_little_endian() helper
      tun: add tun_is_little_endian() helper
      macvtap: introduce macvtap_is_little_endian() helper
      vringh: introduce vringh_is_little_endian() helper
      vhost: introduce vhost_is_little_endian() helper
      virtio: add explicit big-endian support to memory accessors
      vhost: cross-endian support for legacy devices
      macvtap/tun: cross-endian support for little-endian hosts

 drivers/vhost/vhost.h              | 25 ++++++++---
 drivers/virtio/virtio_pci_common.h |  2 +
 include/linux/virtio_byteorder.h   | 24 ++++++-----
 include/linux/virtio_config.h      | 18 +++++---
 include/linux/vringh.h             | 18 +++++---
 include/uapi/linux/if_tun.h        |  6 +++
 include/uapi/linux/vhost.h         | 14 +++++++
 drivers/net/macvtap.c              | 65 ++++++++++++++++++++++++++++-
 drivers/net/tun.c                  | 67 +++++++++++++++++++++++++++++-
 drivers/vhost/vhost.c              | 85 +++++++++++++++++++++++++++++++++++++-
 drivers/virtio/virtio_pci_common.c |  7 ----
 drivers/virtio/virtio_pci_legacy.c | 13 +++++-
 drivers/virtio/virtio_pci_modern.c | 24 ++++++++---
 drivers/net/Kconfig                | 14 +++++++
 drivers/vhost/Kconfig              | 15 +++++++
 15 files changed, 350 insertions(+), 47 deletions(-)
