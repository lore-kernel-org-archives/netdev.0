From: Shuah Khan <shuah.khan@hp.com>
Subject: Re: [PATCH 1/2] dma-debug: Fix locking bug in check_unmap
Date: Tue, 19 Mar 2013 14:29:07 -0600
Message-ID: <1363724947.4519.9.camel@lorien2>
References: <20130318220241.7349.5030.stgit@ahduyck-cp1.jf.intel.com>
	 <20130318221243.7349.64147.stgit@ahduyck-cp1.jf.intel.com>
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
In-Reply-To: <20130318221243.7349.64147.stgit@ahduyck-cp1.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-18 at 15:12 -0700, Alexander Duyck wrote:
> In check_unmap it is possible to get into a dead-locked state if
> dma_mapping_error is called.  The problem is that the bucket is locked in
> check_unmap, and locked again by debug_dma_mapping_error which is called by
> dma_mapping_error.  To resolve that we must release the lock on the bucket
> before making the call to dma_mapping_error.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Looks good.

Reviewed-by: Shuah Khan
Tested-by Shuah Khan

Thanks for finding and fixing the problem.
-- Shuah
