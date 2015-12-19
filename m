From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netcp: fix regression in receive processing
Date: Sat, 19 Dec 2015 00:10:58 -0500 (EST)
Message-ID: <20151219.001058.862320196789855068.davem@davemloft.net>
References: <1651314.QiL8XMyoqS@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w-kwok2@ti.com, m-karicheri2@ti.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1651314.QiL8XMyoqS@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Dec 2015 15:18:08 +0100

> A cleanup patch I did was unfortunately wrong and introduced
> multiple serious bugs in the netcp rx processing, as indicated
> by these correct gcc warnings:
> 
> drivers/net/ethernet/ti/netcp_core.c:776:14: warning: 'buf_ptr' may be used uninitialized in this function [-Wuninitialized]
> drivers/net/ethernet/ti/netcp_core.c:687:14: warning: 'ptr' may be used uninitialized in this function [-Wuninitialized]
> 
> I have checked the patch once more and found that a call to
> get_pkt_info() accidentally got removed in netcp_free_rx_desc_chain,
> and netcp_process_one_rx_packet no longer retrieved the correct
> buffer length. This patch should fix all the known problems,
> but I did not test on real hardware.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 899077791403 ("netcp: try to reduce type confusion in descriptors")

Applied.
