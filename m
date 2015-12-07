From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Mon, 7 Dec 2015 19:07:01 +0200
Message-ID: <20151207190701-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mhocko@suse.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, luto@kernel.org, s-anna@ti.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

The following changes since commit 527e9316f8ec44bd53d90fb9f611fa7ffff52bb9:

  Linux 4.4-rc4 (2015-12-06 15:43:12 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to f277ec42f38f406ed073569b24b04f1c291fec0f:

  virtio_ring: shadow available ring flags & index (2015-12-07 17:28:11 +0200)

----------------------------------------------------------------
virtio: fixes on top of 4.4-rc4

This includes some fixes and cleanups in virtio and vhost code. Most notably,
shadowing the index fixes the excessive cacheline bouncing observed on AMD
platforms.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (5):
      virtio-net: Stop doing DMA from the stack
      vhost: relax log address alignment
      tools/virtio: move list macro stubs
      tools/virtio: fix byteswap logic
      vhost: replace % with & on data path

Michal Hocko (1):
      virtio: Do not drop __GFP_HIGH in alloc_indirect

Suman Anna (1):
      virtio: fix memory leak of virtio ida cache layers

Venkatesh Srinivas (1):
      virtio_ring: shadow available ring flags & index

 tools/virtio/linux/kernel.h        |  6 +++++
 tools/virtio/linux/virtio.h        |  6 -----
 tools/virtio/linux/virtio_config.h | 20 ++++++++++------
 drivers/net/virtio_net.c           | 34 +++++++++++++++------------
 drivers/vhost/vhost.c              |  8 +++----
 drivers/virtio/virtio.c            |  1 +
 drivers/virtio/virtio_ring.c       | 48 +++++++++++++++++++++++++++-----------
 7 files changed, 78 insertions(+), 45 deletions(-)
