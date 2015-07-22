From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: fix ring memory allocation
Date: Tue, 21 Jul 2015 22:35:53 -0700 (PDT)
Message-ID: <20150721.223553.650568423958457767.davem@davemloft.net>
References: <1836998.fscmK2EJWV@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1836998.fscmK2EJWV@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 22 Jul 2015 01:31:59 +0300

> The driver is written as if it can adapt to a low memory situation  allocating
> less RX  skbs and TX aligned buffers than the respective RX/TX ring sizes.  In
> reality  though  the driver  would malfunction in this case. Stop being overly
> smart and just fail in such situation -- this is achieved by moving the memory
> allocation from ravb_ring_format() to ravb_ring_init().
> 
> We leave dma_map_single() calls in place but make their failure non-fatal
> by marking the corresponding RX descriptors  with zero data size which should
> prevent DMA to an invalid addresses.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.

But the real way to handle this is to allocate all of the necessary
resources for the replacement RX SKB before unmapping and passing the
original SKB up into the stack.

That way you _NEVER_ starve the device of RX packets to receive into,
since if you fail the memory allocation or the DMA mapping, you just
put the original SKB back into the ring.
