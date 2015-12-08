From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 8 Dec 2015 12:39:12 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Lu Baolu <baolu.lu@linux.intel.com>
To: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59016 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129AbbLHMjf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 07:39:35 -0500
In-Reply-To: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu [mailto:peter@lekensteyn.nl]
> Sent: Tuesday, December 08, 2015 7:18 PM
> 
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

Acked-by: Hayes Wang <hayeswang@realtek.com>

Best Regards,
Hayes
