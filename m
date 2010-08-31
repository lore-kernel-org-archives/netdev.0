From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 30 Aug 2010 21:43:27 -0700 (PDT)
Message-ID: <20100830.214327.57458877.davem@davemloft.net>
References: <20100831131812.1b8eb758.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, akinobu.mita@gmail.com,
	fujita.tomonori@lab.ntt.co.jp
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100831131812.1b8eb758.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 31 Aug 2010 13:18:12 +1000

> Hi ,
> 
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> drivers/net/starfire.c: In function 'starfire_init':
> drivers/net/starfire.c:2081: error: negative width in bit-field '<anonymous>'
> 
> This is:
> 	BUILD_BUG_ON(sizeof(dma_addr_t) != sizeof(netdrv_addr_t));
> in starfire_init().
> 
> Immediate cause is commit 56543af9563d91c1c5596a7980b416389bdea071
> ("starfire: use BUILD_BUG_ON for netdrv_addr_t").

I anticipated this and Fujita is working on a solution involving
adding a CONFIG_DMA_ADDR_T_64BIT that the starfire can check
instead of that ugly CPP test.
