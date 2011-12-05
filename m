From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: Rx FIFO overflow fixes.
Date: Mon, 05 Dec 2011 18:45:38 -0500 (EST)
Message-ID: <20111205.184538.809640991246086089.davem@davemloft.net>
References: <4ED7E6AB.6050308@wolke7.net>
	<20111201222612.GA27998@electric-eye.fr.zoreil.com>
	<20111205063045.GA3103@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: booster@wolke7.net, hayeswang@realtek.com, jrnieder@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	armin.kazmi@tu-dortmund.de
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111205063045.GA3103@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 5 Dec 2011 07:30:45 +0100

> Realtek has specified that the post 8168c gigabit chips and the post
> 8105e fast ethernet chips recover automatically from a Rx FIFO overflow.
> The driver does not need to clear the RxFIFOOver bit of IntrStatus and
> it should rather avoid messing it.
> 
> The implementation deserves some explanation:
> 1. events outside of the intr_event bit mask are now ignored. It enforces
>    a no-processing policy for the events that either should not be there
>    or should be ignored.
> 
> 2. RxFIFOOver was already ignored in rtl_cfg_infos[RTL_CFG_1] for the
>    whole 8168 line of chips with two exceptions:
>    - RTL_GIGA_MAC_VER_22 since b5ba6d12bdac21bc0620a5089e0f24e362645efd
>      ("use RxFIFO overflow workaround for 8168c chipset.").
>      This one should now be correctly handled.
>    - RTL_GIGA_MAC_VER_11 (8168b) which requires a different Rx FIFO
>      overflow processing.
> 
>    Though it does not conform to Realtek suggestion above, the updated
>    driver includes no change for RTL_GIGA_MAC_VER_12 and RTL_GIGA_MAC_VER_17.
>    Both are 8168b. RTL_GIGA_MAC_VER_12 is common and a bit old so I'd rather
>    wait for experimental evidence that the change suggested by Realtek really
>    helps or does not hurt in unexpected ways.
> 
>    Removed case statements in rtl8169_interrupt are only 8168 relevant.
> 
> 3. RxFIFOOver is masked for post 8105e 810x chips, namely the sole 8105e
>    (RTL_GIGA_MAC_VER_30) itself.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: hayeswang <hayeswang@realtek.com>

Applied.
