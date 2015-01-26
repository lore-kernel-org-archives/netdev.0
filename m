From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Mon, 26 Jan 2015 23:11:49 +0000
Message-ID: <20150126231149.GL26493@n2100.arm.linux.org.uk>
References: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1421937182-1708-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <54C3A1F9.1000403@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	B38611@freescale.com, fabio.estevam@freescale.com,
	David.Laight@ACULAB.COM
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:55966 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665AbbAZXL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 18:11:59 -0500
Content-Disposition: inline
In-Reply-To: <54C3A1F9.1000403@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 24, 2015 at 10:45:29AM -0300, Ezequiel Garcia wrote:
> Hi all,
> 
> On 01/22/2015 11:33 AM, Ezequiel Garcia wrote:
> > Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
> > Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> > Date:   Mon May 19 13:59:59 2014 -0300
> > 
> >     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
> > 
> > caused a nasty regression by removing the support for highmem skb
> > fragments. By using page_address() to get the address of a fragment's
> > page, we are assuming a lowmem page. However, such assumption is incorrect,
> > as fragments can be in highmem pages, resulting in very nasty issues.
> > 
> > This commit fixes this by using the skb_frag_dma_map() helper,
> > which takes care of mapping the skb fragment properly. Additionally,
> > the type of mapping is now tracked, so it can be unmapped using
> > dma_unmap_page or dma_unmap_single when appropriate.
> > 
> > This commit also fixes the error path in txq_init() to release the
> > resources properly.
> > 
> > Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map the skb fragments")
> > Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Russell, when you have some time, please test this patch. I think it
> solves the regression and it manages to unmap the descriptors properly.

Yes, this seems to work as well, thanks.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
