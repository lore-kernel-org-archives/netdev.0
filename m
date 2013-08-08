From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause
 frame
Date: Thu, 8 Aug 2013 20:45:49 +0200
Message-ID: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
References: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>
	  <1375871056-10420-2-git-send-email-claudiu.manoil@freescale.com>
	 <1375902775.2644.98.camel@deadeye.wl.decadent.org.uk>
	 <5203D0E8.8050809@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31277 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966131Ab3HHSpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 14:45:54 -0400
In-Reply-To: <5203D0E8.8050809@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 20:10 +0300, Claudiu Manoil wrote:
> Hi Ben,
> 
> On 8/7/2013 10:12 PM, Ben Hutchings wrote:
> > On Wed, 2013-08-07 at 13:24 +0300, Claudiu Manoil wrote:
> >> Allow Rx/Tx pause frame configuration via ethtool.
> >> The gfar devices feature link autonegotioation by default.
> >
> > So the MAC configuration bits are actually copied to the PHY autoneg
> > basic page, and then the PHY autoneg result is automatically used by the
> > MAC?
> >
> > This is of course possible to do in hardware, but... since this MAC is
> > not smart enough to ignore pause settings when running in half-duplex
> > mode, I seriously doubt it is doing all this by itself.
> >
> 
> I just wanted to say actually that the pause->autoneg parameter is not
> needed by the gianfar driver, but I didn't know what to do with it in
> get_pauseparam(), apparently pause->autoneg needs a value (or can
> simply ignore this param?).
> 
> I don't see what autonegotiation has to do with enabling/disabling
> pause frame generation in this case. My understanding is that link
> autonegotiation is taken care somewhere else, by the phy state machine.
> Each time this happens, the gianfar driver gets notified via the
> adjust_link() hook that it implements and makes the necessary configs
> in the mac registers.

That's what it *should* be doing.  But it's not; it's using
priv->rx_pause and priv->tx_pause, not phydev->pause and
phydev->asym_pause.  I.e. pause autoneg is really always *disabled*.

> Besides, autoneg info is already being displayed by ethtool (see
> print below).
> So I don't understand the use of pause->autoneg. What should I do with
> it?
[...]

Pause frame generation may be forced even though autonegotiation is
enabled.  I don't think this is a good idea but many drivers do support
it.

And gianfar does appear to allow autonegotiation to be disabled, anyway,
so in any case you have to support both forced and autonegotiated cases.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
