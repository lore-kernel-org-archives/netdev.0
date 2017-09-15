From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smsc911x: Quieten netif during suspend
Date: Fri, 15 Sep 2017 14:26:22 -0700 (PDT)
Message-ID: <20170915.142622.1357636170906048191.davem@davemloft.net>
References: <1505324525-9998-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1505324525-9998-1-git-send-email-geert+renesas@glider.be>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Wed, 13 Sep 2017 19:42:05 +0200

> If the network interface is kept running during suspend, the net core
> may call net_device_ops.ndo_start_xmit() while the Ethernet device is
> still suspended, which may lead to a system crash.
> 
> E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
> driven by a PM controlled clock.  If the Ethernet registers are accessed
> while the clock is not running, the system will crash with an imprecise
> external abort.
> 
> As this is a race condition with a small time window, it is not so easy
> to trigger at will.  Using pm_test may increase your chances:
> 
>     # echo 0 > /sys/module/printk/parameters/console_suspend
>     # echo platform > /sys/power/pm_test
>     # echo mem > /sys/power/state
> 
> To fix this, make sure the network interface is quietened during
> suspend.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
