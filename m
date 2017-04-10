From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Tue, 11 Apr 2017 00:36:54 +0300
Message-ID: <20170411003654-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, marc.zyngier@arm.com,
	netdev@vger.kernel.org, efault@gmx.de, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, cornelia.huck@de.ibm.com
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

These changes were as in linux-next as e1c287efcd4cf688564ed1112d032b5dac29b159 -
I tweaked the commit log slightly.

Too many people were complaining of warnings and errors in virtio
so I decided revert is the safest path forward right now.

The following changes since commit a71c9a1c779f2499fb2afc0553e543f18aff6edf:

  Linux 4.11-rc5 (2017-04-02 17:23:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 2f8dc3a01f1cf8ed17b1e295812ad12b688be5d3:

  virtio-pci: Remove affinity hint before freeing the interrupt (2017-04-11 00:30:20 +0300)

----------------------------------------------------------------
virtio: oops fixes

virtio pci rework using shared interrupts caused a lot of issues. We
tried to fix them but run out of time. Revert for now, and revisit the
issue for the next kernel.

Luckily we are able to do this without loosing automatic
interrupt NUMA affinity which was the main motivator for the
rework.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Cornelia Huck (1):
      MAINTAINERS: fix virtio file pattern

Marc Zyngier (1):
      virtio-pci: Remove affinity hint before freeing the interrupt

Michael S. Tsirkin (9):
      virtio_net: enable big packets for large MTU values
      virtio: allow drivers to validate features
      virtio_net: clear MTU when out of range
      virtio_console: fix uninitialized variable use
      Revert "virtio_pci: fix out of bound access for msix_names"
      Revert "virtio_pci: simplify MSI-X setup"
      Revert "virtio_pci: don't duplicate the msix_enable flag in struct pci_dev"
      Revert "virtio_pci: use shared interrupts for virtqueues"
      Revert "virtio_pci: remove struct virtio_pci_vq_info"

 MAINTAINERS                        |   2 +-
 drivers/char/virtio_console.c      |   6 +-
 drivers/net/virtio_net.c           |  45 +++--
 drivers/virtio/virtio.c            |   6 +
 drivers/virtio/virtio_pci_common.c | 375 ++++++++++++++++++++++---------------
 drivers/virtio/virtio_pci_common.h |  43 ++++-
 drivers/virtio/virtio_pci_legacy.c |   8 +-
 drivers/virtio/virtio_pci_modern.c |   8 +-
 include/linux/virtio.h             |   1 +
 include/uapi/linux/virtio_pci.h    |   2 +-
 10 files changed, 323 insertions(+), 173 deletions(-)
