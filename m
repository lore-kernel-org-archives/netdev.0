From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] virtio: virtio 1.0 support, misc patches
Date: Thu, 11 Dec 2014 14:14:20 +0200
Message-ID: <20141211121420.GA9022@redhat.com>
References: <20141211120248.GA8838@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	ben@decadent.org.uk, David Miller <davem@davemloft.net>,
	thuth@linux.vnet.ibm.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141211120248.GA8838@redhat.com>
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

On Thu, Dec 11, 2014 at 02:02:48PM +0200, Michael S. Tsirkin wrote:
> The following changes since commit b2776bf7149bddd1f4161f14f79520f17fc1d71d:
> 
>   Linux 3.18 (2014-12-07 14:21:05 -0800)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> 
> for you to fetch changes up to 803cd18f7b5e6c7ad6bee9571ae8f4450190ab58:

Actually the commit hash in this mail is wrong:
The correct one is
	f01a2a811ae04124fc9382925038fcbbd2f0b7c8
the reason I got this wrong is I prepared the pull request mail several
days ago, and since then I have rebased, pushed, and several people
tested this correct latest hash.

It's all signed correctly, so 

Linus, do I need to resend?

Sorry about the noise.

> 
>   virtio_ccw: finalize_features error handling (2014-12-09 16:32:41 +0200)
> 
> Note: some net drivers are affected by these patches.
> David said he's fine with merging these patches through
> my tree.
> Rusty's on vacation, he acked using my tree for these, too.
> 
> ----------------------------------------------------------------
> virtio: virtio 1.0 support, misc patches
> 
> This adds a lot of infrastructure for virtio 1.0 support.
> Notable missing pieces: virtio pci, virtio balloon (needs spec extension),
> vhost scsi.
> 
> Plus, there are some minor fixes in a couple of places.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> ----------------------------------------------------------------
> Cornelia Huck (4):
>       virtio: allow transports to get avail/used addresses
>       KVM: s390: virtio-ccw revision 1 SET_VQ
>       KVM: s390: enable virtio-ccw revision 1
>       virtio_ccw: finalize_features error handling
> 
> Jason Wang (1):
>       vhost: remove unnecessary forward declarations in vhost.h
> 
> Michael S. Tsirkin (64):
>       virtio: add low-level APIs for feature bits
>       virtio: use u32, not bitmap for features
>       mic_virtio: robust feature array size calculation
>       virtio: add support for 64 bit features.
>       virtio: assert 32 bit features in transports
>       virtio_ccw: add support for 64 bit features.
>       virtio: add virtio 1.0 feature bit
>       virtio: memory access APIs
>       virtio_ring: switch to new memory access APIs
>       virtio_config: endian conversion for v1.0
>       virtio: set FEATURES_OK
>       virtio: simplify feature bit handling
>       virtio: add legacy feature table support
>       virtio_net: v1.0 endianness
>       virtio_blk: v1.0 support
>       KVM: s390 allow virtio_ccw status writes to fail
>       virtio_blk: make serial attribute static
>       virtio_blk: fix race at module removal
>       virtio_net: pass vi around
>       virtio_net: get rid of virtio_net_hdr/skb_vnet_hdr
>       virtio_net: stricter short buffer length checks
>       virtio_net: bigger header when VERSION_1 is set
>       virtio_net: disable mac write for virtio 1.0
>       virtio_net: enable v1.0 support
>       vhost: make features 64 bit
>       vhost: add memory access wrappers
>       vhost/net: force len for TX to host endian
>       vhost: switch to __get/__put_user exclusively
>       vhost: virtio 1.0 endian-ness support
>       vhost/net: virtio 1.0 byte swap
>       vhost/net: larger header for virtio 1.0
>       vhost/net: enable virtio 1.0
>       tun: move internal flag defines out of uapi
>       tun: drop most type defines
>       tun: add VNET_LE flag
>       tun: TUN_VNET_LE support, fix sparse warnings for virtio headers
>       macvtap: TUN_VNET_LE support
>       virtio_scsi: v1.0 support
>       virtio_scsi: move to uapi
>       virtio_scsi: export to userspace
>       vhost/scsi: partial virtio 1.0 support
>       af_packet: virtio 1.0 stubs
>       virtio_console: virtio 1.0 support
>       virtio_balloon: add legacy_only flag
>       virtio: make VIRTIO_F_VERSION_1 a transport bit
>       virtio: drop VIRTIO_F_VERSION_1 from drivers
>       virtio_console: fix sparse warnings
>       virtio: add API to detect legacy devices
>       virtio_ccw: legacy: don't negotiate rev 1/features
>       virtio: allow finalize_features to fail
>       virtio_ccw: rev 1 devices set VIRTIO_F_VERSION_1
>       virtio_balloon: drop legacy_only driver flag
>       virtio: drop legacy_only driver flag
>       virtio_pci: add isr field
>       virtio_pci: fix coding style for structs
>       virtio_pci: free up vq->priv
>       virtio_pci: use priv for vq notification
>       virtio_pci: delete vqs indirectly
>       virtio_pci: setup vqs indirectly
>       virtio_pci: setup config vector indirectly
>       virtio_pci: split out legacy device support
>       virtio_pci: update file descriptions and copyright
>       virtio_pci: rename virtio_pci -> virtio_pci_common
>       virtio_ccw: future-proof finalize_features
> 
> Thomas Huth (1):
>       KVM: s390: Set virtio-ccw transport revision
> 
>  drivers/vhost/vhost.h                  |  41 +-
>  drivers/virtio/virtio_pci_common.h     | 136 ++++++
>  include/linux/virtio.h                 |  12 +-
>  include/linux/virtio_byteorder.h       |  59 +++
>  include/linux/virtio_config.h          | 103 ++++-
>  include/uapi/linux/if_tun.h            |  17 +-
>  include/uapi/linux/virtio_blk.h        |  15 +-
>  include/uapi/linux/virtio_config.h     |   9 +-
>  include/uapi/linux/virtio_console.h    |   7 +-
>  include/uapi/linux/virtio_net.h        |  15 +-
>  include/uapi/linux/virtio_ring.h       |  45 +-
>  include/{ => uapi}/linux/virtio_scsi.h | 106 ++---
>  include/uapi/linux/virtio_types.h      |  46 ++
>  tools/virtio/linux/virtio.h            |  22 +-
>  tools/virtio/linux/virtio_config.h     |   2 +-
>  drivers/block/virtio_blk.c             |  74 +--
>  drivers/char/virtio_console.c          |  39 +-
>  drivers/lguest/lguest_device.c         |  17 +-
>  drivers/misc/mic/card/mic_virtio.c     |  14 +-
>  drivers/net/macvtap.c                  |  68 ++-
>  drivers/net/tun.c                      | 168 +++----
>  drivers/net/virtio_net.c               | 161 +++----
>  drivers/remoteproc/remoteproc_virtio.c |  11 +-
>  drivers/s390/kvm/kvm_virtio.c          |  11 +-
>  drivers/s390/kvm/virtio_ccw.c          | 203 +++++++--
>  drivers/scsi/virtio_scsi.c             |  50 +-
>  drivers/vhost/net.c                    |  31 +-
>  drivers/vhost/scsi.c                   |  22 +-
>  drivers/vhost/vhost.c                  |  93 ++--
>  drivers/virtio/virtio.c                | 102 ++++-
>  drivers/virtio/virtio_mmio.c           |  17 +-
>  drivers/virtio/virtio_pci.c            | 802 ---------------------------------
>  drivers/virtio/virtio_pci_common.c     | 464 +++++++++++++++++++
>  drivers/virtio/virtio_pci_legacy.c     | 326 ++++++++++++++
>  drivers/virtio/virtio_ring.c           | 109 +++--
>  net/packet/af_packet.c                 |  35 +-
>  tools/virtio/virtio_test.c             |   5 +-
>  tools/virtio/vringh_test.c             |  16 +-
>  drivers/virtio/Makefile                |   1 +
>  include/uapi/linux/Kbuild              |   2 +
>  40 files changed, 2048 insertions(+), 1428 deletions(-)
>  create mode 100644 drivers/virtio/virtio_pci_common.h
>  create mode 100644 include/linux/virtio_byteorder.h
>  rename include/{ => uapi}/linux/virtio_scsi.h (73%)
>  create mode 100644 include/uapi/linux/virtio_types.h
>  delete mode 100644 drivers/virtio/virtio_pci.c
>  create mode 100644 drivers/virtio/virtio_pci_common.c
>  create mode 100644 drivers/virtio/virtio_pci_legacy.c
