From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 01/13] b44: allocate tx bounce bufs as needed
Date: Tue, 15 Mar 2005 16:51:49 -0800
Message-ID: <20050315165149.0aa4db6e.davem@davemloft.net>
References: <200503152222.j2FMMW2x016793@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        linville@tuxdriver.com, pp@netppl.fi
To: akpm@osdl.org
In-Reply-To: <200503152222.j2FMMW2x016793@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 14:22:37 -0800
akpm@osdl.org wrote:

> From: "John W. Linville" <linville@tuxdriver.com>
> 
> The b44 hardware has a DMA mask that only covers 1GB.  On x86, a DMA mask
> <4GB results in allocations using GFP_DMA.  The GFP_DMA pool (16MB) gets
> exhausted very quickly in some configurations.
> 
> The b44 driver has been pre-allocating bounce buffers in a single large
> (~750k) contiguous block.  On boxes w/ limited GFP_DMA memory, this
> allocation can fail.  Such failure results in the driver being unable to
> load and function.
> 
> The solution here is to check each tx skb against the DMA mask.  If it is
> outside the allowable range, a single buffer is allocated from the GFP_DMA
> range and discarded after the tx completes.  This behaviour mimics what is
> done for bounce buffers on the rx side.

I think this one is fine and I was expecting Jeff to pick it up
and push upstream.
