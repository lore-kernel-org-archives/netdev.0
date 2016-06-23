From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wlcore: time sync : add support for 64 bit clock
Date: Thu, 23 Jun 2016 13:18:00 +0200
Message-ID: <1466680680.11061.2.camel@sipsolutions.net>
References: <20160623111332.23326-1-yanivma@ti.com>
	 (sfid-20160623_131215_419855_E4550AFE)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>, Guy Mishol <guym@ti.com>,
	Eliad Peller <eliad@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42917 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbcFWLSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 07:18:09 -0400
In-Reply-To: <20160623111332.23326-1-yanivma@ti.com> (sfid-20160623_131215_419855_E4550AFE)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-23 at 14:12 +0300, Yaniv Machani wrote:
> Changed the configuration to support 64bit instead of 32bit
> this in order to offload the driver from handling a wraparound.

[...]

Since you Cc'ed me, and presumably want me to review it, I'll say that
this looks like a terrible idea:

> @@ -74,10 +74,16 @@ struct wl18xx_event_mailbox {

This struct is evidently used for firmware/host communication.

> =C2=A0	__le16 bss_loss_bitmap;
> =C2=A0
> =C2=A0	/* bitmap of stations (by HLID) which exceeded max tx
> retries */
> -	__le32 tx_retry_exceeded_bitmap;
> +	__le16 tx_retry_exceeded_bitmap;
> +
> +	/* time sync high msb*/
> +	u16 time_sync_tsf_high_msb;

So first of all, just using u16 instead of __le16 seems wrong.

Additionally, this looks like it changes the firmware API, so that
older firmware images will no longer work?

johannes
