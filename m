From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the tile
 architecture
Date: Wed, 3 Nov 2010 12:59:59 -0400
Message-ID: <20101103125959.3231daa1@s6510>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Nov 2010 17:00:37 -0400
Chris Metcalf <cmetcalf@tilera.com> wrote:

> This change adds the first network driver for the tile architecture,
> supporting the on-chip XGBE and GBE shims.
> 
> The infrastructure is present for the TILE-Gx networking drivers (another
> three source files in the new directory) but for now the the actual
> tilegx sources are waiting on releasing hardware to initial customers.
> 
> Note that arch/tile/include/hv/* are "upstream" headers from the
> Tilera hypervisor and will probably benefit less from LKML review.
> 

> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> +typedef struct {
> +  /** Byte offset of the next notify packet to be written: zero for the first
> +   *  packet on the queue, sizeof (netio_pkt_t) for the second packet on the
> +   *  queue, etc. */
> +  volatile uint32_t __packet_write;
> +
> +  /** Offset of the packet after the last valid packet (i.e., when any
> +   *  pointer is incremented to this value, it wraps back to zero). */
> +  uint32_t __last_packet_plus_one;
> +}
> +__netio_packet_queue_t;

1. MUST not use volatile, see volatile-considered-harmful.txt
2. SHOULD use __u32 rather than uint32_t in kernel structures
3. MUST not introduce typedef's; use structures
4. SHOULD use proper kernel implementation

If you use scripts/checkpatch.pl it will tell you about these.
