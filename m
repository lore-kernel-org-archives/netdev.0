From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 0/8] vhost-net rx batching
Date: Tue, 21 Mar 2017 12:04:39 +0800
Message-ID: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
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

This series tries to implement rx batching for vhost-net. This is done
by batching the dequeuing from skb_array which was exported by
underlayer socket and pass the sbk back through msg_control to finish
userspace copying.

Tests shows at most 19% improvment on rx pps.

Please review.

Thanks

Jason Wang (8):
  ptr_ring: introduce batch dequeuing
  skb_array: introduce batch dequeuing
  tun: export skb_array
  tap: export skb_array
  tun: support receiving skb through msg_control
  tap: support receiving skb from msg_control
  vhost_net: try batch dequing from skb array
  vhost_net: use lockless peeking for skb array during busy polling

 drivers/net/tap.c         | 25 ++++++++++++++---
 drivers/net/tun.c         | 31 +++++++++++++++------
 drivers/vhost/net.c       | 71 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_tap.h    |  5 ++++
 include/linux/if_tun.h    |  5 ++++
 include/linux/ptr_ring.h  | 65 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h | 25 +++++++++++++++++
 7 files changed, 209 insertions(+), 18 deletions(-)

-- 
2.7.4
