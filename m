From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 4 Jun 2008 17:34:24 +0100
Message-ID: <OFC24FA00D.3871FCA2-ON8025745E.00558124-8025745E.005B0AEE@smsc.com>
References: <20080602155415.GA6192@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>, catalin.marinas@arm.com,
	hennerich@blackfin.uclinux.org, ian.saturley@smsc.com,
	Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	jeff@garzik.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4403 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753645AbYFDQes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 12:34:48 -0400
In-Reply-To: <20080602155415.GA6192@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

> [...]
> > +static void smsc911x_ethtool_setmsglevel(struct net_device *dev, u32 
level)
> > +{
> > +   struct smsc911x_data *pdata = netdev_priv(dev);
> > +   pdata->msg_enable = level;
> > +}
> 
> It would be nice if the logging macros actually tested msg_enable too. 
;-)

I'm implementing this now, using e100's approach (and DPRINTF macro) as a 
guide.
I have a few questions on the "right way" to do this.

1. What's the recommended way to initialise msg_enable? Some drivers set 
it to
a constant, but e100 has a module param called debug and sets msg_enable 
to
((1 << debug) - 1) during probe.  This implies the bits are in order of
importance (i.e. to debug IFDOWN messages one would also have to view DRV,
PROBE, LINK and TIMER messages), is this right?

Once the interface is up, we can turn any combination of bits on and off 
using
ethtool, but a lot of this embedded driver's debugging is done in probe(), 
when
embedded developers/platform integrators are verifying the platform's bus 
layout
and timing.

2. My driver had two levels of message importance (warning and trace), 
chosen
at compile-time so they were #defined out on non-debug builds.  Should I 
remove
this compile-time decision and print the two as KERN_WARNING and 
KERN_DEBUG,
or would printing KERN_DEBUG messages in non-debug builds (when no-one is
interested) be discouraged?

3. DPRINTF adds dev->name to the messages, which is useful.  If I use it 
before
I call register_netdev, dev->name is set to "eth%d" so the debugging 
messages
look strange.  Should I skip the whole msg_enable/DPRINTF thing in probe 
or is
there a better way?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

