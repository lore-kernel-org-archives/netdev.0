From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxa168: fix double deallocation of managed resources
Date: Sun, 26 Apr 2015 16:06:27 -0400 (EDT)
Message-ID: <20150426.160627.2170240613916324389.davem@davemloft.net>
References: <1429924023-11543-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antoine.tenart@free-electrons.com, arnd@arndb.de,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429924023-11543-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 25 Apr 2015 04:07:03 +0300

> Commit 43d3ddf87a57 ("net: pxa168_eth: add device tree support") starts
> to use managed resources by adding devm_clk_get() and
> devm_ioremap_resource(), but it leaves explicit iounmap() and clock_put()
> in pxa168_eth_remove() and in failure handling code of pxa168_eth_probe().
> As a result double free can happen.
> 
> The patch removes explicit resource deallocation. Also it converts
> clk_disable() to clk_disable_unprepare() to make it symmetrical with
> clk_prepare_enable().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied and queued up for -stable, thanks.

I find this patch _extremely_ amusing, as it shows that that these
managed interfaces can be just as error prone to use as the
non-managed ones. :-)
