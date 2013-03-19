From: Shuah Khan <shuah.khan@hp.com>
Subject: Re: [PATCH 2/2] dma-debug: Update DMA debug API to better handle
 multiple mappings of a buffer
Date: Tue, 19 Mar 2013 14:30:22 -0600
Message-ID: <1363725022.4519.11.camel@lorien2>
References: <20130318220241.7349.5030.stgit@ahduyck-cp1.jf.intel.com>
	 <20130318221249.7349.85892.stgit@ahduyck-cp1.jf.intel.com>
Reply-To: shuah.khan@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
	joerg.roedel@amd.com, konrad@kernel.org,
	christoph.paasch@uclouvain.be, mingo@redhat.com, hpa@zytor.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, shuah.khan@hp.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130318221249.7349.85892.stgit@ahduyck-cp1.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-18 at 15:12 -0700, Alexander Duyck wrote:
> There were reports of the igb driver unmapping buffers without calling
> dma_mapping_error.  On closer inspection issues were found in the DMA debug
> API and how it handled multiple mappings of the same buffer.
> 
> The issue I found is the fact that the debug_dma_mapping_error would only set
> the map_err_type to MAP_ERR_CHECKED in the case that the was only one match
> for device and device address.  However in the case of non-IOMMU, multiple
> addresses existed and as a result it was not setting this field once a
> second mapping was instantiated.  I have resolved this by changing the search
> so that it instead will now set MAP_ERR_CHECKED on the first buffer that
> matches the device and DMA address that is currently in the state
> MAP_ERR_NOT_CHECKED.
> 
> A secondary side effect of this patch is that in the case of multiple buffers
> using the same address only the last mapping will have a valid map_err_type.
> The previous mappings will all end up with map_err_type set to
> MAP_ERR_CHECKED because of the dma_mapping_error call in debug_dma_map_page.
> However this behavior may be preferable as it means you will likely only see
> one real error per multi-mapped buffer, versus the current behavior of
> multiple false errors mer multi-mapped buffer.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Looks good. Tested it as well.

Reviewed-by: shuah.khan@hp.com
Tested-by: shuah.khan@hp.com

Thanks for finding and fixing the problem.

-- Shuah
