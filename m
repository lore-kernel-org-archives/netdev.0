From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 2/2] sfc: Reduce RX scatter buffer size, and
 reduce alignment if appropriate
Date: Tue, 14 May 2013 11:32:39 -0700 (PDT)
Message-ID: <20130514.113239.791038636818706716.davem@davemloft.net>
References: <1368482311.3305.48.camel@bwh-desktop.uk.solarflarecom.com>
	<1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, heiko.carstens@de.ibm.com,
	linux-net-drivers@solarflare.com, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 13 May 2013 23:01:22 +0100

> efx_start_datapath() asserts that we can fit 2 RX scatter buffers plus
> a software structure, each appropriately aligned, into a single page.
> Where L1_CACHE_BYTES == 256 and PAGE_SIZE == 4096, which is the case
> on s390, this assertion fails.
> 
> The current scatter buffer size is also not a multiple of 64 or 128,
> which are more common cache line sizes.  If we can make both the start
> and end of a scatter buffer cache-aligned, this will reduce the need
> for read-modify-write operations on inter- processor links.
> 
> Fix the alignment by reducing EFX_RX_USR_BUF_SIZE to 2048 - 256 ==
> 1792.  (We could use 2048 - L1_CACHE_BYTES, but EFX_RX_USR_BUF_SIZE
> also affects user-level networking where a larger amount of
> housekeeping data may be needed.  Although this version of the driver
> does not support user-level networking, I prefer to keep scattering
> behaviour consistent with the out-of-tree version.)
> 
> This still doesn't fix the s390 build because like most architectures
> it has NET_IP_ALIGN == 2.  When NET_IP_ALIGN != 0 we cannot achieve
> cache line alignment at either the start or end of a scatter buffer,
> so there is actually no point in padding the buffers to a multiple of
> the cache line size.  All we need is 4-byte alignment of the network
> header, so do that.
> 
> Adjust the assertions accordingly.
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
