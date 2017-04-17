From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] sh_eth: unmap DMA buffers when freeing rings
Date: Mon, 17 Apr 2017 16:10:51 -0400 (EDT)
Message-ID: <20170417.161051.805859402797991771.davem@redhat.com>
References: <20170417125532.826640693@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        horms@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170417125532.826640693@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 17 Apr 2017 15:55:22 +0300

> The DMA API debugging (when enabled) causes:
> 
> WARNING: CPU: 0 PID: 1445 at lib/dma-debug.c:519 add_dma_entry+0xe0/0x12c
> DMA-API: exceeded 7 overlapping mappings of cacheline 0x01b2974d
> 
> to be  printed after repeated initialization of the Ether device, e.g.
> suspend/resume or 'ifconfig' up/down. This is because DMA buffers mapped
> using dma_map_single() in sh_eth_ring_format() and sh_eth_start_xmit() are
> never unmapped. Resolve this problem by unmapping the buffers when freeing
> the descriptor  rings;  in order  to do it right, we'd have to add an extra
> parameter to sh_eth_txfree() (we rename this function to sh_eth_tx_free(),
> while at it).
> 
> Based on the commit a47b70ea86bd ("ravb: unmap descriptors when freeing
> rings").
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
