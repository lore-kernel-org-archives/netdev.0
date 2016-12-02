From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: altera: TSE: do not use tx queue
 lock in tx completion handler
Date: Fri, 02 Dec 2016 12:11:54 -0500 (EST)
Message-ID: <20161202.121154.2111120437823188386.davem@davemloft.net>
References: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
        <1480546112-3099-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, nios2-dev@lists.rocketboards.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480546112-3099-2-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Wed, 30 Nov 2016 23:48:32 +0100

> The driver already uses its private lock for synchronization between xmit
> and xmit completion handler making the additional use of the xmit_lock
> unnecessary.
> Furthermore the driver does not set NETIF_F_LLTX resulting in xmit to be
> called with the xmit_lock held and then taking the private lock while xmit
> completion handler does the reverse, first take the private lock, then the
> xmit_lock.
> Fix these issues by not taking the xmit_lock in the tx completion handler.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Yeah that could be a nasty deadlock, in fact.

Applied, thanks.
