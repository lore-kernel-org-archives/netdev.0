From: Christoph Hellwig <hch@lst.de>
Subject: clean up and modularize arch dma_mapping interface
Date: Thu,  8 Jun 2017 15:25:25 +0200
Message-ID: <20170608132609.32662-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-mips@linux-mips.org, openrisc@lists.librecores.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
 linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org,
 netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi all,

for a while we have a generic implementation of the dma mapping routines
that call into per-arch or per-device operations.  But right now there
still are various bits in the interfaces where don't clearly operate
on these ops.  This series tries to clean up a lot of those (but not all
yet, but the series is big enough).  It gets rid of the DMA_ERROR_CODE
way of signaling failures of the mapping routines from the
implementations to the generic code (and cleans up various drivers that
were incorrectly using it), and gets rid of the ->set_dma_mask routine
in favor of relying on the ->dma_capable method that can be used in
the same way, but which requires less code duplication.

Btw, we don't seem to have a tree every-growing amount of common dma
mapping code, and given that I have a fair amount of all over the tree
work in that area in my plate I'd like to start one.  Any good reason
to that?  Anyone willing to volunteer as co maintainer?

The whole series is also available in git:

    git://git.infradead.org/users/hch/misc.git dma-map

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/dma-map
