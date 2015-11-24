From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: stmmac: Free rx_skbufs before realloc
Date: Tue, 24 Nov 2015 13:09:24 -0500 (EST)
Message-ID: <20151124.130924.1365382562223060152.davem@davemloft.net>
References: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
	<1448181858-5935-2-git-send-email-zhengsq@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	dianders@google.com
To: zhengsq@rock-chips.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448181858-5935-2-git-send-email-zhengsq@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shunqian Zheng <zhengsq@rock-chips.com>
Date: Sun, 22 Nov 2015 16:44:18 +0800

> From: ZhengShunQian <zhengsq@rock-chips.com>
> 
> The init_dma_desc_rings() may realloc the rx_skbuff[] when
> suspend and resume. This patch free the rx_skbuff[] before
> reallocing memory.
> 
> Signed-off-by: ZhengShunQian <zhengsq@rock-chips.com>

This isn't really the right way to fix this.

I see two reasonable approaches:

1) suspend liberates the RX ring, although this approach is less
   desirable

2) resume doesn't try to allocate already populated RX ring
   entries

Freeing the whole RX ring just to allocate it again immediately
makes no sense at all and is wasteful work.
