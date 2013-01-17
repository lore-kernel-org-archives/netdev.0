From: akong@redhat.com
Subject: [PATCH v3 0/2] make mac programming for virtio net more robust
Date: Thu, 17 Jan 2013 18:40:10 +0800
Message-ID: <1358419212-32356-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: mst@redhat.com
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

From: Amos Kong <akong@redhat.com>

Currenly mac is programmed byte by byte. This means that we
have an intermediate step where mac is wrong. 

Second patch introduced a new vq control command to set mac
address, it's atomic.

V2: check return of sending command, delay eth_mac_addr()
V3: restore software address when fail to set hardware address

Amos Kong (2):
  move virtnet_send_command() above virtnet_set_mac_address()
  virtio-net: introduce a new control to set macaddr

 drivers/net/virtio_net.c        | 110 +++++++++++++++++++++++-----------------
 include/uapi/linux/virtio_net.h |   8 ++-
 2 files changed, 71 insertions(+), 47 deletions(-)

-- 
1.7.11.7
