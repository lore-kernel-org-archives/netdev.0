From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 6 Dec 2006 21:52:35 +0100
Message-ID: <200612062152.36475.mb@bu3sch.de>
References: <4576D778.mailLQC18T1PN@lwfinger.net> <200612061852.04216.mb@bu3sch.de> <20061206201715.GA23021@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:38801
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937630AbWLFUw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 15:52:59 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061206201715.GA23021@p15091797.pureserver.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 December 2006 21:17, Ulrich Kunitz wrote:
> On 06-12-06 18:52 Michael Buesch wrote:
> 
> > All data in mac->associnfo is protected by mac->associnfo->mutex
> > and _not_ mac->lock.
> 
> Are you sure?

Yes I am.

> One can find for instance the following function in 
> ieee80211softmac_assoc.c:

This is not the first time we notice that locking
is completely broken in softmac. ;)

> void
> ieee80211softmac_disassoc(struct ieee80211softmac_device *mac)
> {
>         unsigned long flags;
> 
>         spin_lock_irqsave(&mac->lock, flags);
>         if (mac->associnfo.associating)
>                 cancel_delayed_work(&mac->associnfo.timeout);
> 
>         netif_carrier_off(mac->dev);
> 
>         mac->associnfo.associated = 0;
>         mac->associnfo.bssvalid = 0;
>         mac->associnfo.associating = 0;
>         ieee80211softmac_init_bss(mac);
>         ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
>         spin_unlock_irqrestore(&mac->lock, flags);
> }
> 
> Cheers,
> 
> Uli
> 

-- 
Greetings Michael.
