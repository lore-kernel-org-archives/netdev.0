From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: enhance TX path with
 recycling more SKBs in one poll
Date: Tue, 11 Apr 2017 10:49:24 -0400 (EDT)
Message-ID: <20170411.104924.1724009300333538121.davem@davemloft.net>
References: <1491899667-19596-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491899667-19596-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Tue, 11 Apr 2017 16:34:27 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> The patch adds the enhancement for recycling more TX completed SKBs in
> one NAPI polling handler if NAPI budgets are still available and hardware
> raises status bit shown for certain SKBs are aready done.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

You should always, unconditionally, process all TX reclaim events
every NAPI poll, regardless of how much budget is left.

TX reclaim work is not counted against the NAPI budget, only RX work
should be.
