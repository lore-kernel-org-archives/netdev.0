From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 0/5] Series short description
Date: Mon, 05 Dec 2011 16:58:37 +0800
Message-ID: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

multiple queue virtio-net: flow steering through host/guest cooperation

Hello all:

This is a rough series adds the guest/host cooperation of flow
steering support based on Krish Kumar's multiple queue virtio-net
driver patch 3/3 (http://lwn.net/Articles/467283/).

This idea is simple, the backend pass the rxhash to the guest and
guest would tell the backend the hash to queue mapping when necessary
then backend can choose the queue based on the hash value of the
packet.  The table is just a page shared bettwen userspace and the
backend.

Patch 1 enable the ability to pass the rxhash through vnet_hdr to
guest.
Patch 2,3 implement a very simple flow director for tap and
mavtap. tap part is based on the multiqueue tap patches posted by me
(http://lwn.net/Articles/459270/).
Patch 4 implement a method for virtio device to find the irq of a
specific virtqueue, in order to do device specific interrupt
optimization
Patch 5 is the part of the guest driver that using accelerate rfs to
program the flow director and with some optimizations on irq affinity
and tx queue selection.

This is just a prototype that demonstrates the idea, there are still
things need to be discussed:

- An alternative idea instead of shared page is ctrl vq, the reason
  that a shared table is preferable is the delay of ctrl vq itself.
- Optimization on irq affinity and tx queue selection

Comments are welcomed, thanks!

---

Jason Wang (5):
      virtio_net: passing rxhash through vnet_hdr
      tuntap: simple flow director support
      macvtap: flow director support
      virtio: introduce a method to get the irq of a specific virtqueue
      virtio-net: flow director support


 drivers/lguest/lguest_device.c |    8 ++
 drivers/net/macvlan.c          |    4 +
 drivers/net/macvtap.c          |   42 ++++++++-
 drivers/net/tun.c              |  105 ++++++++++++++++------
 drivers/net/virtio_net.c       |  189 +++++++++++++++++++++++++++++++++++++++-
 drivers/s390/kvm/kvm_virtio.c  |    6 +
 drivers/vhost/net.c            |   10 +-
 drivers/vhost/vhost.h          |    5 +
 drivers/virtio/virtio_mmio.c   |    8 ++
 drivers/virtio/virtio_pci.c    |   12 +++
 include/linux/if_macvlan.h     |    1 
 include/linux/if_tun.h         |   11 ++
 include/linux/virtio_config.h  |    4 +
 include/linux/virtio_net.h     |   16 +++
 14 files changed, 377 insertions(+), 44 deletions(-)

-- 
Signature
