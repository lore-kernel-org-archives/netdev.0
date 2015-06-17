From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [arc-linux-dev] [PATCH] stmmac: explicitly zero des0 & des1 on
 init
Date: Wed, 17 Jun 2015 07:03:25 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075665A5DED@IN01WEMBXB.internal.synopsys.com>
References: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Arnd Bergmann <arnd@arndb.de>
To: "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+CC linux-arch, linux-mm, Arnd and Marek

On Tuesday 16 June 2015 11:11 PM, Alexey Brodkin wrote:

Current implementtion of descriptor init procedure only takes care about
ownership flag. While it is perfectly possible to have underlying memory
filled with garbage on boot or driver installation.

And randomly set flags in non-zeroed des0 and des1 fields may lead to
unpredictable behavior of the GMAC DMA block.

Solution to this problem is as simple as explicit zeroing of both des0
and des1 fields of all buffer descriptors.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com><mailto:abrodkin@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com><mailto:peppe.cavallaro@st.com>
Cc: arc-linux-dev@synopsys.com<mailto:arc-linux-dev@synopsys.com>
Cc: linux-kernel@vger.kernel.org<mailto:linux-kernel@vger.kernel.org>
Cc: stable@vger.kernel.org<mailto:stable@vger.kernel.org>

FWIW, this was causing sporadic/random networking flakiness on ARC SDP platform (scheduled for upstream inclusion in next window)

This also leads to an interesting question - should arch/*/dma_alloc_coherent() and friends unconditionally zero out memory (vs. the current semantics of letting only doing it based on gfp, as requested by driver). This is the second instance we ran into stale descriptor memory, the first one was in dw_mmc driver which was recently fixed in upstream as well (although debugged independently by Alexey and using the upstream fix)

http://www.spinics.net/lists/linux-mmc/msg31600.html

The pros is better out of box experience (despite buggy drivers) while the cons are they remain broken and perhaps increased boot time due to extra memzero....

Thx,
-Vineet
