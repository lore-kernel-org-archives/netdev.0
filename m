From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 0/4] Send gratuitous packets by guest
Date: Thu, 27 Oct 2011 16:48:26 +0800
Message-ID: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	stefanha@gmail.com
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
as tagged vlan or ipv6, those connections may be lost or stalled after
migration.

One method to handle them is snooping the network traffic in qemu and
recording use of mac, but this method would hurt performance and is
impossible for network backend such as vhost.

So the best method to address it is to let guest instead of qemu to
send gratuitous packet. This series first add a model specific
fucntion which can let nic model to implement its own announce
method and then implement a virtio-net specific function to
let guest send the gratitous packet.

Changes from v2:

- Conditionally send the notification interrupt to guest (only for
migration, cont, loadvm).
- Remove the unused patch of function export.
- Typos and other comments from Stefan Hajnoczi.
- Disable guest announce for compat machine types.

---

Jason Wang (4):
      announce self after vm start
      net: model specific announcing support
      virtio-net: notify guest to annouce itself
      virtio-net: compat guest announce support.


 gdbstub.c       |    2 +-
 hw/pc_piix.c    |   16 ++++++++++++++++
 hw/virtio-net.c |   18 +++++++++++++++++-
 hw/virtio-net.h |    3 +++
 migration.c     |    4 ++--
 monitor.c       |    4 ++--
 net.h           |    2 ++
 savevm.c        |   10 ++++++----
 sysemu.h        |    2 +-
 vl.c            |    7 +++++--
 10 files changed, 55 insertions(+), 13 deletions(-)

-- 
Jason Wang
