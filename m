From: Amos Kong <akong@redhat.com>
Subject: [PATCH v5 0/3] make mac programming for virtio net more robust
Date: Mon, 21 Jan 2013 19:17:20 +0800
Message-ID: <1358767043-24548-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, mst@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org
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

Currenly mac is programmed byte by byte. This means that we
have an intermediate step where mac is wrong. 

Third patch introduced a new vq control command to set mac
address, it's atomic.

V2: check return of sending command, delay eth_mac_addr()
V3: restore software address when fail to set hardware address
V4: split eth_mac_addr, fix error handle
V5: rebase patches to net-next tree

Amos Kong (2):
  move virtnet_send_command() above virtnet_set_mac_address()
  virtio-net: introduce a new control to set macaddr

Stefan Hajnoczi (1):
  net: split eth_mac_addr for better error handling

 drivers/net/virtio_net.c        |  110 ++++++++++++++++++++++-----------------
 include/linux/etherdevice.h     |    2 +
 include/uapi/linux/virtio_net.h |    8 +++-
 net/ethernet/eth.c              |   41 ++++++++++++--
 4 files changed, 106 insertions(+), 55 deletions(-)
