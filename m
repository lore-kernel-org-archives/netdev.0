From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: mediatek: add support for IRQ grouping
Date: Wed, 13 Apr 2016 22:22:38 -0400 (EDT)
Message-ID: <20160413.222238.1174020501502372148.davem@davemloft.net>
References: <1460053499-53659-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, matthias.bgg@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: blogic@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460053499-53659-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <blogic@openwrt.org>
Date: Thu,  7 Apr 2016 20:24:59 +0200

> The ethernet core has 3 IRQs. Using the IRQ grouping registers we are able
> to separate TX and RX IRQs, which allows us to service them on separate
> cores. This patch splits the IRQ handler into 2 separate functions, one
> for TX and another for RX. The TX housekeeping is split out of the NAPI
> handler. Instead we use a tasklet to handle housekeeping.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>

Don't do this with tasklets.

Do your TX reclaim in a NAPI poll just like the RX side.
