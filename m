From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH next] drivers: wireless: carl9170: shrink carl9170_tx_info
Date: Sat, 14 Mar 2015 12:51:57 +0100
Message-ID: <1689955.Ikz24aORLX@debian64>
References: <1426261045-22373-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:33285 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbbCNLwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 07:52:08 -0400
In-Reply-To: <1426261045-22373-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 13, 2015 04:37:25 PM Florian Westphal wrote:
> its embededded inside rate_driver_data of the ieee80211_tx_info struct,
> which in turn is stored in skb->cb[].
> 
> In order to shrink cb, we need to shrink ieee80211_tx_info which means
> to downsize all users first.
> 
> Alternatively, one might be able to remove kref but
> its less intrusive/simpler to use u32 for timeout handling.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
u32 jiffies... that's a lot of pointing (well not so much) and really 
ugly casting (a lot). I guess it would be easier to just use a "per-queue"
timeout watchdog like almost everybody else. This way, the driver will
be ready for the next skb->cb shrink as well.

carl9170_tx_ampdu_timeout can be completely removed.

Regards,
  Christian
