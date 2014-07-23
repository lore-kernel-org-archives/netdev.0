From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH v3 net-next 0/2] rx busy polling support for virtio-net
Date: Wed, 23 Jul 2014 16:33:53 +0800
Message-ID: <1406104435-24077-1-git-send-email-jasowang@redhat.com>
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
was useful for reduing the latency for a kvm guest. Instead of
introducing new states and spinlocks, this series re-uses NAPI state
to synchonrize between NAPI and busy polling. This grealy simplified
the codes and reduce the overheads of spinlocks for normal NAPI fast
path.

Test was done between a kvm guest and an external host. Two hosts were
connected through 40gb mlx4 cards. With both busy_poll and  busy_read
are set to 50 in guest, 1 byte netperf tcp_rr shows 127% improvement:
transaction rate was increased from 8353.33 to 18966.87.

Changes from V2:
- Avoid introducing new states and spinlocks by reusuing the NAPI
  state
- Fix the budget calculation in virtnet_poll()
- Drop patch 1/3 from V2 since it was useless

Changes from V1:
- split the patch info smaller ones
- add more details about test setup/configuration

Jason Wang (2):
  virtio-net: introduce virtnet_receive()
  virtio-net: rx busy polling support

 drivers/net/virtio_net.c | 67 +++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 61 insertions(+), 6 deletions(-)

-- 
1.8.3.1
