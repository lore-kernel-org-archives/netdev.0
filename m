From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] zd1211rw: replace ZD_ASSERT with
 lockdep_assert_held()
Date: Thu, 11 Sep 2014 12:12:25 +0200
Message-ID: <1410430345.22863.0.camel@jlt4.sipsolutions.net>
References: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
	 <1410430179-19944-1-git-send-email-sanjeev_sharma@mentor.com>
	 (sfid-20140911_121019_335368_163BEA7C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dsd@gentoo.org, kune@deine-taler.de,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55918 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881AbaIKKMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 06:12:32 -0400
In-Reply-To: <1410430179-19944-1-git-send-email-sanjeev_sharma@mentor.com> (sfid-20140911_121019_335368_163BEA7C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-11 at 15:39 +0530, Sanjeev Sharma wrote:
> on some architecture spin_is_locked() always return false in
> uniprocessor configuration and therefore it would be advise
> to replace with lockdep_assert_held().
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
> Changes in v2:
>   - corrected the typo

Now it compiles, but you got the logic wrong.

> +++ b/drivers/net/wireless/zd1211rw/zd_mac.c
> @@ -235,7 +235,7 @@ void zd_mac_clear(struct zd_mac *mac)
>  {
>  	flush_workqueue(zd_workqueue);
>  	zd_chip_clear(&mac->chip);
> -	ZD_ASSERT(!spin_is_locked(&mac->lock));
> +	lockdep_assert_held(&mac->lock);
>  	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
>  }

Look closely at this again.

johannes
