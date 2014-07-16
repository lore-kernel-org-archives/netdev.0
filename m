From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 0/3] rx busy polling support for virtio-net
Date: Wed, 16 Jul 2014 14:21:44 +0800
Message-ID: <1405491707-22706-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au, mst@redhat.com,
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

This series introduces the support for rx busy polling support. This
was useful for reduing the latency for a kvm guest. Patch 1-2
introduces helpers which is used for rx busy polling. Patch 3
implement the main function.

Test was done between a kvm guest and an external host. Two hosts were
connected through 40gb mlx4 cards. With both busy_poll and busy_read are
set to 50 in guest, 1 byte netperf tcp_rr shows 116% improvement:
transaction rate was increased from 9151.94 to 19787.37.

Changes from V1:
- split the patch info smaller ones
- add more details about test setup/configuration

Please review.

Jason Wang (3):
  virtio-net: introduce helpers to enable and disable all NAPIs
  virtio-net: introduce virtnet_receive()
  virtio-net: rx busy polling support

 drivers/net/virtio_net.c | 234 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 221 insertions(+), 13 deletions(-)

-- 
1.8.3.1
