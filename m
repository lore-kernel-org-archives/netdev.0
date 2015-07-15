From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost: cleanups and fixes
Date: Wed, 15 Jul 2015 14:26:43 +0300
Message-ID: <20150715142438-mutt-send-email-mst@redhat.com>
References: <20150715135024-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, thuth@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, pmorel@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	borntraeger@de.ibm.com, yan@daynix.com, imammedo@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20150715135024-mutt-send-email-mst@redhat.com>
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

On Wed, Jul 15, 2015 at 01:50:24PM +0300, Michael S. Tsirkin wrote:
> The following changes since commit 59a5b0f7bf74f88da6670bcbf924d8cc1e75b1ee:
> 
>   virtio-pci: alloc only resources actually used. (2015-06-24 08:15:09 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> 
> for you to fetch changes up to c9ce42f72fd0ba180fd35539829e4139dca31494:
> 
>   vhost: add max_mem_regions module parameter (2015-07-13 23:17:19 +0300)
> 
> ----------------------------------------------------------------
> virtio/vhost: fixes for 4.2
> 
> Bugfixes and documentation fixes. Igor's patch that allows
> users to tweak memory table size is borderline,
> but it does fix known crashes, so I merged it.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Ouch.  Turns out there was a bug in error handling here.
Linus, please don't pull this one yet, I will fix it up and
resend. I've deleted the tag for now so it won't get pulled
by mistake.

> ----------------------------------------------------------------
> Cornelia Huck (2):
>       MAINTAINERS: separate section for s390 virtio drivers
>       virtio/s390: rename drivers/s390/kvm -> drivers/s390/virtio
> 
> Igor Mammedov (3):
>       vhost: use binary search instead of linear in find_region()
>       vhost: extend memory regions allocation to vmalloc
>       vhost: add max_mem_regions module parameter
> 
> Michael S. Tsirkin (2):
>       virtio_net: document VIRTIO_NET_CTRL_GUEST_OFFLOADS
>       virtio: define virtio_pci_cfg_cap in header.
> 
> Pierre Morel (1):
>       9p/trans_virtio: reset virtio device on remove
> 
> Stephen Rothwell (1):
>       virtio scsi: fix unused variable warning
> 
> Thomas Huth (1):
>       virtio: Fix typecast of pointer in vring_init()
> 
>  include/uapi/linux/virtio_net.h           | 16 ++++++++
>  include/uapi/linux/virtio_pci.h           |  6 +++
>  include/uapi/linux/virtio_ring.h          |  5 ++-
>  drivers/s390/{kvm => virtio}/kvm_virtio.c |  0
>  drivers/s390/{kvm => virtio}/virtio_ccw.c |  0
>  drivers/scsi/virtio_scsi.c                |  4 +-
>  drivers/vhost/vhost.c                     | 67 +++++++++++++++++++++++--------
>  net/9p/trans_virtio.c                     |  1 +
>  MAINTAINERS                               | 10 ++++-
>  drivers/s390/Makefile                     |  2 +-
>  drivers/s390/{kvm => virtio}/Makefile     |  0
>  11 files changed, 91 insertions(+), 20 deletions(-)
>  rename drivers/s390/{kvm => virtio}/kvm_virtio.c (100%)
>  rename drivers/s390/{kvm => virtio}/virtio_ccw.c (100%)
>  rename drivers/s390/{kvm => virtio}/Makefile (100%)
