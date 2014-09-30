From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet : stmicro: fixed power suspend and
 resume failure in stmmac driver
Date: Tue, 30 Sep 2014 15:10:56 -0400 (EDT)
Message-ID: <20140930.151056.950254777090461575.davem@davemloft.net>
References: <1412056534-7995-1-git-send-email-hliang1025@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, adi-linux-docs@lists.sourceforge.net
To: hliang1025@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412056534-7995-1-git-send-email-hliang1025@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <hliang1025@gmail.com>
Date: Tue, 30 Sep 2014 13:55:34 +0800

> From: Hao Liang <hliang1025@gmail.com>
> 
> This is the fix for a power management issue caused by suspend and resume function in stmmac_main.c.
> After enable CONFIG_DEBUG_ATOMIC_SLEEP which enable sleep-inside atomic section checking, power
> managemet can not work normally. Board couldn't wakeup successfully after suspend. Command
> "echo mem > /sys/power/state" suspend the board.
> 
> In suspend and resume function of stmmac driver, there are some sleep-inside function in atomic section
> created by spin lock. These functions will causes system warnings and wakeup issue when enable
> CONFIG_DEBUG_ATOMIC_SLEEP.
> 
> This bug was fixed by:
> * replace some sleep function with non-sleep function
>   clk_disable_unprepare -> clk_disable ...
> * decrease the atomic area created by spin lock function. The original atomic area in resume function is
> too large.
> 
> Signed-off-by: Hao Liang <hliang1025@gmail.com>

I really think the ->mac->xxx calls need to be under the lock, and therefore this
spinlock region shortening is not valid.
