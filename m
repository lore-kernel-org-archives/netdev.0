From: tndave <tushar.n.dave@oracle.com>
Subject: Re: clean up and modularize arch dma_mapping interface V2
Date: Wed, 21 Jun 2017 12:24:28 -0700
Message-ID: <162d7932-5766-4c29-5471-07d1b699190a@oracle.com>
References: <20170616181059.19206-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
Content-Language: en-US
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org



On 06/16/2017 11:10 AM, Christoph Hellwig wrote:
> Hi all,
> 
> for a while we have a generic implementation of the dma mapping routines
> that call into per-arch or per-device operations.  But right now there
> still are various bits in the interfaces where don't clearly operate
> on these ops.  This series tries to clean up a lot of those (but not all
> yet, but the series is big enough).  It gets rid of the DMA_ERROR_CODE
> way of signaling failures of the mapping routines from the
> implementations to the generic code (and cleans up various drivers that
> were incorrectly using it), and gets rid of the ->set_dma_mask routine
> in favor of relying on the ->dma_capable method that can be used in
> the same way, but which requires less code duplication.
Chris,

Thanks for doing this.
So archs can still have their own definition for dma_set_mask() if 
HAVE_ARCH_DMA_SET_MASK is y?
(and similarly for dma_set_coherent_mask() when 
CONFIG_ARCH_HAS_DMA_SET_COHERENT_MASK is y)
Any plan to change these?

I'm in a process of making some changes to SPARC iommu so it would be 
good to know. Thanks.

-Tushar

> 
> I've got a good number of reviews last time, but a few are still missing.
> I'd love to not have to re-spam everyone with this patchbomb, so early
> ACKs (or complaints) are welcome.
> 
> I plan to create a new dma-mapping tree to collect all this work.
> Any volunteers for co-maintainers, especially from the iommu gang?
> 
> The whole series is also available in git:
> 
>      git://git.infradead.org/users/hch/misc.git dma-map
> 
> Gitweb:
> 
>      http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/dma-map
> 
> Changes since V1:
>   - remove two lines of code from arm dmabounce
>   - a few commit message tweaks
>   - lots of ACKs
> 
