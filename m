From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Tue, 29 Oct 2013 22:42:27 -0400 (EDT)
Message-ID: <20131029.224227.1700872646112764527.davem@davemloft.net>
References: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tdmackey@booleanhaiku.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Mackey <tdmackey@booleanhaiku.com>
Date: Tue, 29 Oct 2013 15:16:38 -0700

> Using dev_kfree_skb_any() will resolve the below issue when a
> netconsole message is transmitted in an irq.
 ...
> Signed-off-by: David Mackey <tdmackey@booleanhaiku.com>

This is absolutely not the correct fix.

The netpoll facility must invoke ->poll() in an environment which
is compatible, locking and interrupt/soft-interrupt wise, as that
in which it is normally called.

Therefore, bnx2_tx_int(), which is invoked from the driver's ->poll()
method, should not need to use dev_kfree_skb_any().  The real problem
is somewhere else.
