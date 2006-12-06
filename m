From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 6 Dec 2006 21:17:15 +0100
Message-ID: <20061206201715.GA23021@p15091797.pureserver.info>
References: <4576D778.mailLQC18T1PN@lwfinger.net> <200612061852.04216.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:59855 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937606AbWLFURQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 15:17:16 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200612061852.04216.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-06 18:52 Michael Buesch wrote:

> All data in mac->associnfo is protected by mac->associnfo->mutex
> and _not_ mac->lock.

Are you sure? One can find for instance the following function in
ieee80211softmac_assoc.c:

void
ieee80211softmac_disassoc(struct ieee80211softmac_device *mac)
{
        unsigned long flags;

        spin_lock_irqsave(&mac->lock, flags);
        if (mac->associnfo.associating)
                cancel_delayed_work(&mac->associnfo.timeout);

        netif_carrier_off(mac->dev);

        mac->associnfo.associated = 0;
        mac->associnfo.bssvalid = 0;
        mac->associnfo.associating = 0;
        ieee80211softmac_init_bss(mac);
        ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
        spin_unlock_irqrestore(&mac->lock, flags);
}

Cheers,

Uli

-- 
Uli Kunitz
