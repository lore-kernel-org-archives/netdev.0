From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] brcmfmac: cfg80211: use msecs_to_jiffies for time
	conversion
Date: Wed, 18 Mar 2015 07:44:39 +0100
Message-ID: <20150318064439.GA25924@opentech.at>
References: <1426593972-17652-1-git-send-email-hofrat@osadl.org> <1426596159.23897.61.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:56513 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbbCRGow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 02:44:52 -0400
Content-Disposition: inline
In-Reply-To: <1426596159.23897.61.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015, Joe Perches wrote:

> On Tue, 2015-03-17 at 08:06 -0400, Nicholas Mc Guire wrote:
> > Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> > OK but msecs_to_jiffies(val) is the cleaner solution and handles all
> > corner cases correctly. This is a minor API consolidation only and
> > should make things more readable.
> 
> Hi Nicholas
> 
> These API consolidation changes now always have a function
> call when the compiler may have previously been able to
> optimize out the "constant * HZ / 1000" calculation.
>
> Perhaps the [um]secs_to_jiffies calls should be indirected
> with yet another static inline with a __builtin_constant_p()
> test so that the function calls can again be avoided when
> possible.

will give it a try 

> 
> (and a trivial style note)
> 
> > diff --git a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
> []
> > @@ -1110,7 +1110,7 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
> >  
> >  	/* Arm scan timeout timer */
> >  	mod_timer(&cfg->escan_timeout, jiffies +
> > -			WL_ESCAN_TIMER_INTERVAL_MS * HZ / 1000);
> > +		  msecs_to_jiffies(WL_ESCAN_TIMER_INTERVAL_MS));
> 
> It may be nicer to keep the arithmetic on one line

sorry that was plain carelessness afer it went over 80 char.

> 
>  	mod_timer(&cfg->escan_timeout,
> 		  jiffies + msecs_to_jiffies(WL_ESCAN_TIMER_INTERVAL_MS));
>

thx!
hofrat 
