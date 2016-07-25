From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/ncsi: avoid maybe-uninitialized warning
Date: Mon, 25 Jul 2016 10:33:31 -0700 (PDT)
Message-ID: <20160725.103331.1354056319823788243.davem@davemloft.net>
References: <20160721192927.3182806-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gwshan@linux.vnet.ibm.com, joel@jms.id.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160721192927.3182806-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 21 Jul 2016 21:28:34 +0200

> gcc-4.9 and higher warn about the newly added NSCI code:
> 
> net/ncsi/ncsi-manage.c: In function 'ncsi_process_next_channel':
> net/ncsi/ncsi-manage.c:1003:2: error: 'old_state' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The warning is a false positive and therefore harmless, but it would be good to
> avoid it anyway. I have determined that the barrier in the spin_unlock_irqsave()
> is what confuses gcc to the point that it cannot track whether the variable
> was unused or not.
> 
> This rearranges the code in a way that makes it obvious to gcc that old_state
> is always initialized at the time of use, functionally this should not
> change anything.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
