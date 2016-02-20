From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Fri, 19 Feb 2016 23:55:33 -0500 (EST)
Message-ID: <20160219.235533.1135050085277533832.davem@davemloft.net>
References: <1455807427-3177-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455807427-3177-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Thu, 18 Feb 2016 22:57:07 +0800

> There will be a log spam when there is no cable plugged.
> Please refer to following links.
> https://bugzilla.kernel.org/show_bug.cgi?id=104351
> https://bugzilla.kernel.org/show_bug.cgi?id=107421
> 
> This issue is caused by runtime power management. When there is no cable
> plugged, the driver will be suspend (runtime suspend) by OS and NIC will
> be put into the D3 state. During this time, if OS call rtl8169_get_stats64()
> to dump tally counter, because NIC is in D3 state, the register value read by
> driver will return all 0xff. This will let driver think tally counter flag is not
> toggled and then sends the warning  message "rtl_counters_cond == 1 (loop: 1000,
> delay: 10)" to kernel log.
> 
> I add checking driver's pm runtime status in rtl8169_get_stats64() to fix
> this issue.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

If you are going to do this, then you need to quiesce the device RX/TX
and capture all of the statistics from the chip before suspending it.

Otherwise what we're returning from rtl8169_get_stats64() is inaccurate.
