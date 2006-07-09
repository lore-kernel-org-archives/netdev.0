From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible
Date: Mon, 10 Jul 2006 01:04:52 +0200
Message-ID: <200607100104.53006.mb@bu3sch.de>
References: <200607092047.57256.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:12193
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932485AbWGIXFi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 19:05:38 -0400
To: linville@tuxdriver.com
In-Reply-To: <200607092047.57256.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 09 July 2006 20:47, you wrote:
> ===================================================================
> --- wireless-dev-dscapeports.orig/net/d80211/ieee80211.c	2006-06-17 21:26:10.000000000 +0200
> +++ wireless-dev-dscapeports/net/d80211/ieee80211.c	2006-07-09 20:01:42.000000000 +0200
> @@ -4327,8 +4327,7 @@
>  		del_timer_sync(&local->rate_limit_timer);
>  	if (local->stat_time)
>  		del_timer_sync(&local->stat_timer);
> -	if (local->scan_timer.data)
> -		del_timer_sync(&local->scan_timer);
> +	cancel_rearming_delayed_work(&local->scan_work);
>  	ieee80211_rx_bss_list_deinit(dev);
>  
>  	rtnl_lock();

There seems to be a problem. It sometimes loops inside of
cancel_rearming_delayed_work forever. So I tried to fix it like this:
	if (local->scan_work.data)
		cancel_rearming_delayed_work(&local->scan_work);
This fixes the case where we don't scan (have no STA), so don't
initialize the work struct.

But it still loops infinite, sometimes.
Any suggestions?

-- 
Greetings Michael.
