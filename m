From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 00:25:14 -0400 (EDT)
Message-ID: <20141015.002514.384962932982389732.davem@davemloft.net>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, netdev@vger.kernel.org, LeoLi@freescale.com,
	linux-doc@vger.kernel.org
To: Jiafei.Pan@freescale.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Jiafei <Jiafei.Pan@freescale.com>
Date: Wed, 15 Oct 2014 11:26:11 +0800

> In some platform, there are some hardware block provided
> to manage buffers to improve performance. So in some case,
> it is expected that the packets received by some generic
> NIC should be put into such hardware managed buffers
> directly, so that such buffer can be released by hardware
> or by driver.
> 
> This patch provide such general APIs for generic NIC to
> use hardware block managed buffers without any modification
> for generic NIC drivers.

Why are existing interfaces insufficent for your needs?

Several ethernet drivers already build SKBs from block
buffer pools.

They allocate pools of pages which the hardware divides into various
powers of 2, then the RX descriptor says what pieces of which pools
were used to hold the data for a packet, and then the SKB is
constructed with page frags pointing to those locations.

It's very cheap, inexpensive, and existing APIs are considered to
cover all use cases.
