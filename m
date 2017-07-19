From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 0/5] Refine virtio-net XDP
Date: Wed, 19 Jul 2017 16:54:44 +0800
Message-ID: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	jasowang@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
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

Hi:

This series brings two optimizations for virtio-net XDP:

- avoid reset during XDP set
- turn off offloads on demand

Changes from V1:
- Various tweaks on commit logs and comments
- Use virtnet_napi_enable() when enabling NAPI on XDP set
- Copy the small buffer packet only if xdp_headroom is smaller than
  required

Please review.

Thanks

Jason Wang (5):
  virtio_ring: allow to store zero as the ctx
  virtio-net: pack headroom into ctx for mergeable buffers
  virtio-net: switch to use new ctx API for small buffer
  virtio-net: do not reset during XDP set
  virtio-net: switch off offloads on demand if possible on XDP set

 drivers/net/virtio_net.c     | 332 ++++++++++++++++++++++++++-----------------
 drivers/virtio/virtio_ring.c |   2 +-
 2 files changed, 200 insertions(+), 134 deletions(-)

-- 
2.7.4
