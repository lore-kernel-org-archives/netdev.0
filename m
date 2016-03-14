From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix lock imbalance in vmxnet3_tq_xmit()
Date: Mon, 14 Mar 2016 13:11:01 -0400 (EDT)
Message-ID: <20160314.131101.1124355509776435130.davem@davemloft.net>
References: <1457967280-4014226-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, sbhatewara@vmware.com,
	gyang@vmware.com, nhorman@tuxdriver.com, khoroshilov@ispras.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457967280-4014226-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 15:53:57 +0100

> A recent bug fix rearranged the code in vmxnet3_tq_xmit() in a
> way that left the error handling for oversized headers unlock
> a lock that had not been taken yet. Gcc warns about the incorrect
> use of the 'flags' variable because of that:
> 
> drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_tq_xmit.constprop':
> include/linux/spinlock.h:246:3: error: 'flags' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This changes the error handling path to 'goto' the end of the function
> beyond the lock/unlock pair.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: cec05562fb1d ("vmxnet3: avoid calling pskb_may_pull with interrupts disabled")

Applied and queued up for -stable, thanks.
