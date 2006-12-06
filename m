From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 6 Dec 2006 18:52:03 +0100
Message-ID: <200612061852.04216.mb@bu3sch.de>
References: <4576D778.mailLQC18T1PN@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kune@deine-taler.de, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39356
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936942AbWLFRwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:52:38 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4576D778.mailLQC18T1PN@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 December 2006 15:45, Larry Finger wrote:
> From:  Ulrich Kunitz <kune@deine-taler.de>
>  
> A deauthentication from the AP doesn't start a reassociation by
> SoftMAC. To fix this mac->associnfo.associating must be set and the
> ieee80211softmac_assoc_work function must be scheduled.
> 
> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
>  net/ieee80211/softmac/ieee80211softmac_assoc.c |   14 ++++++++++++--
>  net/ieee80211/softmac/ieee80211softmac_auth.c  |    2 ++
>  net/ieee80211/softmac/ieee80211softmac_priv.h  |    2 ++
>  3 files changed, 16 insertions(+), 2 deletions(-)
> 
> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
> @@ -427,6 +427,17 @@ ieee80211softmac_handle_assoc_response(s
>  	return 0;
>  }
>  
> +void
> +ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&mac->lock, flags);
> +	mac->associnfo.associating = 1;
> +	schedule_work(&mac->associnfo.work);
> +	spin_unlock_irqrestore(&mac->lock, flags);
> +}

All data in mac->associnfo is protected by mac->associnfo->mutex
and _not_ mac->lock.

-- 
Greetings Michael.
