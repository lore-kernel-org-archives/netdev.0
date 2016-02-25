From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Thu, 25 Feb 2016 16:19:47 -0500 (EST)
Message-ID: <20160225.161947.854773663623773324.davem@davemloft.net>
References: <1456294722-3596-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456294722-3596-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Wed, 24 Feb 2016 14:18:42 +0800

> There will be a log spam when there is no cable plugged. Please refer to
> following links. https://bugzilla.kernel.org/show_bug.cgi?id=104351
> https://bugzilla.kernel.org/show_bug.cgi?id=107421
> 
> This issue is caused by runtime power management. When there is no cable
> plugged, the driver will be suspend (runtime suspend) by OS and NIC will be
> put into the D3 state. During this time, if OS call rtl8169_get_stats64()
> to dump tally counter, because NIC is in D3 state, the register value read
> by driver will return all 0xff. This will let driver think tally counter
> flag is not toggled and then sends the warning message "rtl_counters_cond
> == 1 (loop: 1000, delay: 10)" to kernel log.
> 
> For fixing this issue, 1.add checking driver's pm runtime status in
> rtl8169_get_stats64(). 2.dump tally counter before going runtime suspend
> for counter accuracy in runtime suspend.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Applied, thanks.
