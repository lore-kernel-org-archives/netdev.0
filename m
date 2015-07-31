From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V4.2] rtlwifi: Fix NULL dereference when PCI driver used as an AP
Date: Fri, 31 Jul 2015 06:26:40 +0000 (UTC)
Message-ID: <20150731062640.B4461140A9B@smtp.codeaurora.org>
References: <1438222280-4146-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Luis Felipe Dominguez Vega <lfdominguez@nauta.cu>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38798 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbbGaG0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:26:41 -0400
In-Reply-To: <1438222280-4146-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Luis Felipe Dominguez Vega <lfdominguez@nauta.cu>
> 
> In commit 33511b157bbcebaef853cc1811992b664a2e5862 ("rtlwifi: add support to
> send beacon frame"), the mechanism for sending beacons was established. That
> patch works correctly for rtl8192cu, but there is a possibility of getting
> the following warnings in the PCI drivers:
> 
> WARNING: CPU: 1 PID: 2439 at net/mac80211/driver-ops.h:12
> ieee80211_bss_info_change_notify+0x179/0x1d0 [mac80211]()
> wlp5s0:  Failed check-sdata-in-driver check, flags: 0x0
> 
> The warning is followed by a NULL pointer dereference as follows:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000006
> IP: [<ffffffffc073998e>] rtl_get_tcb_desc+0x5e/0x760 [rtlwifi]
> 
> This problem was reported at http://thread.gmane.org/gmane.linux.kernel.wireless.general/138645,
> but no solution was found at that time.
> 
> The problem was also reported at https://bugzilla.kernel.org/show_bug.cgi?id=9744
> and this solution was developed and tested there.
> 
> The USB driver works with a NULL final argument in the adapter_tx() callback;
> however, the PCI drivers need a struct rtl_tcb_desc in that position.
> 
> Fixes: 33511b157bbc ("rtlwifi: add support to send beacon frame.")
> Signed-off-by: Luis Felipe Dominguez Vega <lfdominguez@nauta.cu>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [3.19+]

Thanks, applied to wireless-drivers.git.

But I added Fixes line to make it clear what commit this fixes.

Kalle Valo
