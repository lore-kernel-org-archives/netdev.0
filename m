From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 0/4] Support sending gratuitous by guest
Date: Sat, 22 Oct 2011 13:38:27 +0800
Message-ID: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

We only track primary mac address in qemu and send rarp packets after
migration to notify the switch to update its mac address table. This
may not works when guest have complicated network configurations such
as tagged vlan or ipv6, those connection may lost or stall after
migration.

One method to handle them is snooping the network traffic in qemu and
recording use of mac, but this method would hurt performance and is
impossible for network backend such as vhost.

So in order to solve this issue, the best method is to let guest
instead of qemu to send gratuitous packet. This series first add a
model specific fucntion which can let nic model to implement its own
announce function and then implement a virtio-net specific function to
let guest send the gratitous packet.

Only basic test were done.

Comments are welcomed.

Thanks

---

Jason Wang (4):
      announce self after vm start
      net: export announce_self_create()
      net: model specific announcing support
      virtio-net: notify guest to annouce itself


 hw/virtio-net.c |   20 +++++++++++++++++++-
 hw/virtio-net.h |    2 ++
 migration.c     |    1 -
 net.c           |   31 +++++++++++++++++++++++++++++++
 net.h           |    3 +++
 savevm.c        |   40 +++++-----------------------------------
 vl.c            |    1 +
 7 files changed, 61 insertions(+), 37 deletions(-)

-- 
Jason Wang
