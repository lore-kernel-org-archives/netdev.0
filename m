From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B
 under ChromeOS
Date: Wed, 20 Nov 2013 00:40:26 -0500 (EST)
Message-ID: <20131120.004026.2013972041095203460.davem@davemloft.net>
References: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, davemloft@davemloft.net,
	louis@asix.com.tw, allan@asix.com.tw, grundler@google.com,
	daniel@asix.com.tw
To: freddy@asix.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab3KTFk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 00:40:28 -0500
In-Reply-To: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: freddy@asix.com.tw
Date: Wed, 20 Nov 2013 10:11:36 +0800

> From: Freddy Xin <freddy@asix.com.tw>
> 
> This patch adds a workaroud to solve Suspend/Resume issue that AX88772B turns
> off its Ethernet PHY power in the case that REMOTE_WAKEUP feature doesn't
> be set when system suspend. In this case, the PHY power will not be turned
> on again when system resume, so the HW reset must be added in the resume function.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>
> Tested-by: Grant Grundler <grundler@chromium.org>

Like many similar patches I've seen recently, you cannot do this.

Now the the configuration that software things the PHY has is no
longer accurate.

If you absolutely must reset the chip on resume, you have to reprogram
the PHY with whatever settings were existed at the time of the suspend.
