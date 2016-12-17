From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvpp2: fix dma unmapping of TX buffers for
 fragments
Date: Sat, 17 Dec 2016 16:26:58 +0100
Message-ID: <20161217162658.63bc2423@free-electrons.com>
References: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <20161217.102057.1497114610120684110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        stefanc@marvell.com, nadavh@marvell.com, hannah@marvell.com,
        yehuday@marvell.com, raphael.glon@corp.ovh.com,
        stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20161217.102057.1497114610120684110.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, 17 Dec 2016 10:20:57 -0500 (EST), David Miller wrote:

> You're really destroying cache locality, and making things overly
> complicated, by having two arrays.  Actually this is now the third in
> this structure alone.  That's crazy.
> 
> Just have one array for the TX ring software state:
> 
> struct tx_buff_info {
> 	struct sk_buff	*skb;
> 	dma_addr_t	dma_addr;
> 	unsigned int	size;
> };
> 
> Then in the per-cpu TX struct:
> 
> 	struct tx_buff_info	*info;
> 
> This way every data access by the cpu for processing a ring entry
> will be localized, increasing cache hit rates.
> 
> This also significantly simplifies the code that allocates and
> frees this memory.

Yes, I was thinking of moving towards a single array, as it's indeed
crazy to have three arrays for that. However, since it's a fix going
into stable, I also wanted to keep it as simple/straightforward as
possible and avoid refactoring other parts of the code.

If you however believe moving to one array should be done as part of
the fix, I'll do this.

Thanks for your feedback,

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
