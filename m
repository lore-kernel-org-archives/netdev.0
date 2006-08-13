From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] zd1211rw: cleanups
Date: Sun, 13 Aug 2006 11:24:34 +0200
Message-ID: <200608131124.34935.mb@bu3sch.de>
References: <20060812170017.278D08E7782@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35726
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750822AbWHMJZz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 05:25:55 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060812170017.278D08E7782@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 August 2006 19:00, Daniel Drake wrote:
> --- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
> +++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
> @@ -127,11 +127,9 @@ out:
>  
>  void zd_mac_clear(struct zd_mac *mac)
>  {
> -	/* Aquire the lock. */
> -	spin_lock(&mac->lock);
> -	spin_unlock(&mac->lock);
>  	zd_chip_clear(&mac->chip);
> -	memset(mac, 0, sizeof(*mac));
> +	ZD_ASSERT(!spin_is_locked(&mac->lock));

I think this assertion will always trigger on UP kernels
with spinlock debugging disabled.

-- 
Greetings Michael.
