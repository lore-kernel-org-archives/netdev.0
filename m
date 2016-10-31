From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [net-next PATCH RFC 04/26] arch/arm: Add option to skip sync on
 DMA map and unmap
Date: Mon, 31 Oct 2016 10:20:57 +0000
Message-ID: <20161031102057.GZ1041@n2100.armlinux.org.uk>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120447.16276.50401.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, brouer@redhat.com, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161024120447.16276.50401.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 08:04:47AM -0400, Alexander Duyck wrote:
> The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
> APIs in the arch/arm folder.  This change is meant to correct that so that
> we get consistent behavior.

I'm really not convinced that this is anywhere close to correct behaviour.

If we're DMA-ing to a buffer, and we unmap it or sync_for_cpu, then we
will want to access the DMA'd data - especially in the sync_for_cpu case,
it's pointless to call sync_for_cpu if we're not going to access the
data.

So the idea of skipping the CPU copy when DMA_ATTR_SKIP_CPU_SYNC is set
seems to be completely wrong - it means we end up reading the stale data
that was in the buffer, completely ignoring whatever was DMA'd to it.

What's the use case for DMA_ATTR_SKIP_CPU_SYNC ?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
