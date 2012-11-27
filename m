From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc v7 0/3] Multiqueue virtio-net
Date: Tue, 27 Nov 2012 18:15:57 +0800
Message-ID: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com, krkumar2@in.ibm.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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

Hi all:

This series is an update version of multiqueue virtio-net driver based on
Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
packets reception and transmission. Please review and comments.

A protype implementation of qemu-kvm support could by found in
git://github.com/jasowang/qemu-kvm-mq.git. To start a guest with two queues, you
could specify the queues parameters to both tap and virtio-net like:

./qemu-kvm -netdev tap,queues=2,... -device virtio-net-pci,queues=2,...

then enable the multiqueue through ethtool by:

ethtool -L eth0 combined 2

Changes from V6:
- Align the implementation with the RFC spec update v5
- Addressing Rusty's comments:
  * split the patches
  * rename to max_queue_pairs and curr_queue_pairs
  * remove the useless status
  * fix the hibernation bug
- Addressing Ben's comments:
  * check other parameters in ethtool_set_queues

Changes from v5:
- Align the implementation with the RFC spec update v4
- Switch the mode between single mode and multiqueue mode without reset
- Remove the 256 limitation of queues
- Use helpers to do the mapping between virtqueues and tx/rx queues
- Use commbined channels instead of separated rx/tx queus when do the queue
number configuartion
- Other coding style comments from Michael

Changes from V4:
- Add ability to negotiate the number of queues through control virtqueue
- Ethtool -{L|l} support and default the tx/rx queue number to 1
- Expose the API to set irq affinity instead of irq itself

Changes from V3:
- Rebase to the net-next
- Let queue 2 to be the control virtqueue to obey the spec
- Prodives irq affinity
- Choose txq based on processor id

Reference:
- Virtio spec RFC: http://patchwork.ozlabs.org/patch/201303/
- V6: https://lkml.org/lkml/2012/10/30/127
- V5: http://lwn.net/Articles/505388/
- V4: https://lkml.org/lkml/2012/6/25/120
- V2: http://lwn.net/Articles/467283/


Perf Numbers:

Will do some basic test and post as a reply to this mail.

Jason Wang (3):
  virtio-net: separate fields of sending/receiving queue from
    virtnet_info
  virtio_net: multiqueue support
  virtio-net: change the number of queues through ethtool

 drivers/net/virtio_net.c        |  716 ++++++++++++++++++++++++++++-----------
 include/uapi/linux/virtio_net.h |   16 +
 2 files changed, 536 insertions(+), 196 deletions(-)
