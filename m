From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 08 Dec 2015 22:48:42 -0500 (EST)
Message-ID: <20151208.224842.1810870878153442975.davem@davemloft.net>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	baolu.lu@linux.intel.com
To: peter@lekensteyn.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Wu <peter@lekensteyn.nl>
Date: Tue,  8 Dec 2015 12:17:42 +0100

> When an interface is brought up which was previously suspended (via
> runtime PM), it would hang. This happens because napi_disable is called
> before napi_enable.
> 
> Solve this by avoiding napi_enable in the resume during open function
> (netif_running is true when open is called, IFF_UP is set after a
> successful open; netif_running is false when close is called, but IFF_UP
> is then still set).
> 
> While at it, remove WORK_ENABLE check from rtl8152_open (introduced with
> the original change) because it cannot happen:
> 
>  - After this patch, runtime resume will not set it during rtl8152_open.
>  - When link is up, rtl8152_open is not called.
>  - When link is down during system/auto suspend/resume, it is not set.
> 
> Fixes: 41cec84cf285 ("r8152: don't enable napi before rx ready")
> Link: https://lkml.kernel.org/r/20151205105912.GA1766@al
> Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> ---
>  v2: moved rtl_runtime_suspend_enable from close to rtl8152_suspend

Applied, and queued up for -stable, thanks.
