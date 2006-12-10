From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ieee80211softmac: Fix mutex_lock at exit of ieee80211_softmac_get_genie
Date: Sun, 10 Dec 2006 18:51:31 +0100
Message-ID: <200612101851.32274.mb@bu3sch.de>
References: <20061210172701.GA29871@p15091797.pureserver.info> <1165772658.3131.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54378
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762284AbWLJRvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 12:51:47 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1165772658.3131.34.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 December 2006 18:44, Johannes Berg wrote:
> On Sun, 2006-12-10 at 18:27 +0100, Ulrich Kunitz wrote:
> > ieee80211softmac_wx_get_genie locks the associnfo mutex at
> > function exit. This patch fixes it. The patch is against Linus'
> > tree (commit af1713e0).
> 
> Looks good, I wonder how this slipped in.

Nobody calls this function, as it's rather useless. ;)

> Acked-by: Johannes Berg <johannes@sipsolutions.net>
> 
> > Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> > ---
> >  net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
> > index 480d72c..fa2f7da 100644
> > --- a/net/ieee80211/softmac/ieee80211softmac_wx.c
> > +++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
> > @@ -463,7 +463,7 @@ ieee80211softmac_wx_get_genie(struct net
> >  			err = -E2BIG;
> >  	}
> >  	spin_unlock_irqrestore(&mac->lock, flags);
> > -	mutex_lock(&mac->associnfo.mutex);
> > +	mutex_unlock(&mac->associnfo.mutex);
> >  
> >  	return err;
> >  }
> 

-- 
Greetings Michael.
