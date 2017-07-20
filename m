From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: Push the request_irq function
 to the end of probe
Date: Thu, 20 Jul 2017 15:28:31 -0700 (PDT)
Message-ID: <20170720.152831.802536956243282259.davem@davemloft.net>
References: <1500550192-6550-1-git-send-email-j-keerthy@ti.com>
        <5259f0e7-cc5d-35c9-8f09-94cf7b40f653@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j-keerthy@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        johan@kernel.org, ivan.khoronzhuk@linaro.org, t-kristo@ti.com,
        nsekhar@ti.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5259f0e7-cc5d-35c9-8f09-94cf7b40f653@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 20 Jul 2017 11:08:09 -0500

> In general patch looks good to me, but it's really unexpected to
> receive IRQs while CPSW is probing ;(

This is a poor expectation.

Boot loaders and other entities can leave the device in any state
whatsoever.

Furthermore, enabling an IRQ whose handler cannot properly execute
without crashing is wrong fundamentally.  All data structures and
state must be set up properly before the IRQ is requested.

Therefore this patch is correct and I will apply it.
