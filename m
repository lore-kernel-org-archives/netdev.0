From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: davicom: dm9000: Avoid spinlock recursion
 during dm9000_timeout routine
Date: Wed, 07 Jun 2017 14:38:44 -0400 (EDT)
Message-ID: <20170607.143844.682492319776197931.davem@davemloft.net>
References: <1496758626-2726-1-git-send-email-liu.xiang6@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        liuxiang1999@gmail.com
To: liu.xiang6@zte.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496758626-2726-1-git-send-email-liu.xiang6@zte.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Xiang <liu.xiang6@zte.com.cn>
Date: Tue,  6 Jun 2017 22:17:06 +0800

> On the DM9000B, dm9000_phy_write() is called after the main spinlock
> is held, during the dm9000_timeout() routine. Spinlock recursion
> occurs because the main spinlock is requested again in
> dm9000_phy_write(). So spinlock should be avoided in phy operation
> during the dm9000_timeout() routine.
> 
> ---
> v2:
>    dm9000_phy_write_reg is extracted from dm9000_phy_write, with no lock,
>    do the real phy operation.

I told you during your first submission that this is racy.

Conditional locking in multithreaded driver almost never works
properly.

Once we enter the timeout, another asynchronous thread of control (an
interrupt, timer, whatever) can try to do a PHY operation and skip the
locking because the timeout boolean is set.

That's not right.

You will need to find a more correct solution to this locking problem.

Thanks.
