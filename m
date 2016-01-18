From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: virtio pull for 4.5 (was Re: [PULL] virtio: barrier rework+fixes)
Date: Mon, 18 Jan 2016 15:21:59 +0200
Message-ID: <20160118152028-mutt-send-email-mst@redhat.com>
References: <20160113182855-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: aquini@redhat.com, kvm@vger.kernel.org, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	alexander.duyck@gmail.com,
	virtualization@lists.linux-foundation.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, dave@stgolabs.net,
	linux@arm.linux.org.uk, dbueso@suse.de, richard@nod.at,
	bjorn.andersson@sonymobile.com, rmk+kernel@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, james.hogan@imgtec.com,
	arnd@arndb.de, julian.calaby@gmail.com, boqun.feng@gmail.com,
	schwidefsky@de.ibm.com, stefanha@redhat.com, tglx@linutronix.de,
	tony.luck@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	minchan@kernel.org, david.vrabel@citrix.com, joe@perches.com,
	akpm@linux-foundation.org, davem@davemloft.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160113182855-mutt-send-email-mst@redhat.com>
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

Hi Linus,
Just making sure nothing's wrong with this pull request.
If there's an issue, pls let me know!
Thanks!

On Wed, Jan 13, 2016 at 06:28:55PM +0200, Michael S. Tsirkin wrote:
> The following changes since commit afd2ff9b7e1b367172f18ba7f693dfb62bdcb2dc:
> 
>   Linux 4.4 (2016-01-10 15:01:32 -0800)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> 
> for you to fetch changes up to 43e361f23c49dbddf74f56ddf6cdd85c5dbff6da:
> 
>   checkpatch: add virt barriers (2016-01-12 20:47:08 +0200)
> 
> ----------------------------------------------------------------
> virtio: barrier rework+fixes
> 
> This adds a new kind of barrier, and reworks virtio and xen
> to use it.
> Plus some fixes here and there.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> ----------------------------------------------------------------
> 
> Yes I know that the patch by Davidlohr Bueso has a typo in the subject :(
> 
> Davidlohr Bueso (1):
>       lcoking/barriers, arch: Use smp barriers in smp_store_release()
> 
> Michael S. Tsirkin (40):
>       asm-generic: guard smp_store_release/load_acquire
>       ia64: rename nop->iosapic_nop
>       ia64: reuse asm-generic/barrier.h
>       powerpc: reuse asm-generic/barrier.h
>       s390: reuse asm-generic/barrier.h
>       sparc: reuse asm-generic/barrier.h
>       arm: reuse asm-generic/barrier.h
>       arm64: reuse asm-generic/barrier.h
>       metag: reuse asm-generic/barrier.h
>       mips: reuse asm-generic/barrier.h
>       x86/um: reuse asm-generic/barrier.h
>       x86: reuse asm-generic/barrier.h
>       asm-generic: add __smp_xxx wrappers
>       powerpc: define __smp_xxx
>       arm64: define __smp_xxx
>       arm: define __smp_xxx
>       blackfin: define __smp_xxx
>       ia64: define __smp_xxx
>       metag: define __smp_xxx
>       mips: define __smp_xxx
>       s390: define __smp_xxx
>       sh: define __smp_xxx, fix smp_store_mb for !SMP
>       sparc: define __smp_xxx
>       tile: define __smp_xxx
>       xtensa: define __smp_xxx
>       x86: define __smp_xxx
>       asm-generic: implement virt_xxx memory barriers
>       Revert "virtio_ring: Update weak barriers to use dma_wmb/rmb"
>       virtio_ring: update weak barriers to use virt_xxx
>       sh: support 1 and 2 byte xchg
>       sh: move xchg_cmpxchg to a header by itself
>       virtio_ring: use virt_store_mb
>       xenbus: use virt_xxx barriers
>       xen/io: use virt_xxx barriers
>       xen/events: use virt_xxx barriers
>       s390: use generic memory barriers
>       s390: more efficient smp barriers
>       checkpatch.pl: add missing memory barriers
>       checkpatch: check for __smp outside barrier.h
>       checkpatch: add virt barriers
> 
> Minchan Kim (2):
>       virtio_balloon: fix race by fill and leak
>       virtio_balloon: fix race between migration and ballooning
> 
> Stefan Hajnoczi (1):
>       virtio: make find_vqs() checkpatch.pl-friendly
> 
>  arch/arm/include/asm/barrier.h         |  35 ++---------
>  arch/arm64/include/asm/barrier.h       |  19 ++----
>  arch/blackfin/include/asm/barrier.h    |   4 +-
>  arch/ia64/include/asm/barrier.h        |  24 +++-----
>  arch/metag/include/asm/barrier.h       |  55 +++++------------
>  arch/mips/include/asm/barrier.h        |  51 +++++-----------
>  arch/powerpc/include/asm/barrier.h     |  33 ++++------
>  arch/s390/include/asm/barrier.h        |  23 ++++---
>  arch/sh/include/asm/barrier.h          |   3 +-
>  arch/sh/include/asm/cmpxchg-grb.h      |  22 +++++++
>  arch/sh/include/asm/cmpxchg-irq.h      |  11 ++++
>  arch/sh/include/asm/cmpxchg-llsc.h     |  25 +-------
>  arch/sh/include/asm/cmpxchg-xchg.h     |  51 ++++++++++++++++
>  arch/sh/include/asm/cmpxchg.h          |   3 +
>  arch/sparc/include/asm/barrier_32.h    |   1 -
>  arch/sparc/include/asm/barrier_64.h    |  29 ++-------
>  arch/sparc/include/asm/processor.h     |   3 -
>  arch/tile/include/asm/barrier.h        |   9 +--
>  arch/x86/include/asm/barrier.h         |  36 +++++------
>  arch/x86/um/asm/barrier.h              |   9 +--
>  arch/xtensa/include/asm/barrier.h      |   4 +-
>  drivers/virtio/virtio_pci_common.h     |   2 +-
>  include/asm-generic/barrier.h          | 106 ++++++++++++++++++++++++++++++---
>  include/linux/virtio_config.h          |   2 +-
>  include/linux/virtio_ring.h            |  21 +++++--
>  include/xen/interface/io/ring.h        |  16 ++---
>  arch/ia64/kernel/iosapic.c             |   6 +-
>  drivers/gpu/drm/virtio/virtgpu_kms.c   |   2 +-
>  drivers/misc/mic/card/mic_virtio.c     |   2 +-
>  drivers/remoteproc/remoteproc_virtio.c |   2 +-
>  drivers/rpmsg/virtio_rpmsg_bus.c       |   2 +-
>  drivers/s390/virtio/kvm_virtio.c       |   2 +-
>  drivers/s390/virtio/virtio_ccw.c       |   2 +-
>  drivers/virtio/virtio_balloon.c        |   4 +-
>  drivers/virtio/virtio_input.c          |   2 +-
>  drivers/virtio/virtio_mmio.c           |   2 +-
>  drivers/virtio/virtio_pci_common.c     |   4 +-
>  drivers/virtio/virtio_pci_modern.c     |   2 +-
>  drivers/virtio/virtio_ring.c           |  15 +++--
>  drivers/xen/events/events_fifo.c       |   3 +-
>  drivers/xen/xenbus/xenbus_comms.c      |   8 +--
>  mm/balloon_compaction.c                |   4 +-
>  Documentation/memory-barriers.txt      |  28 +++++++--
>  scripts/checkpatch.pl                  |  33 +++++++++-
>  44 files changed, 401 insertions(+), 319 deletions(-)
>  create mode 100644 arch/sh/include/asm/cmpxchg-xchg.h
