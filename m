From: Steve.Glendinning@smsc.com
Subject: Re: [RFC PATCH 2/2] refactor full duplex flow control resolution
Date: Mon, 29 Dec 2008 17:12:51 +0000
Message-ID: <OF7B34BB2C.B6A69F84-ON8025752E.005E7485-8025752E.005EAB70@smsc.com>
References: <1230054335.3402.29.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ian.saturley@smsc.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3407 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751801AbYL2ROO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 12:14:14 -0500
In-Reply-To: <1230054335.3402.29.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben, this looks good.

Do you want to submit a patch for this or should I?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com



Ben Hutchings <bhutchings@solarflare.com> wrote on 23/12/2008 17:45:35:

> On Sun, 2008-12-14 at 12:38 +0000, Steve Glendinning wrote:
> [...]
> > +/**
> > + * mii_resolve_flowctrl_fdx
> > + * @lcladv: value of MII ADVERTISE register
> > + * @rmtadv: value of MII LPA register
> > + *
> > + * Resolve full duplex flow control as per IEEE 802.3-2005 table 
28B-3
> > + */
> > +static inline u8 mii_resolve_flowctrl_fdx(u16 lcladv, u16 rmtadv)
> > +{
> > +   u8 cap = 0;
> > +
> > +   if (lcladv & ADVERTISE_PAUSE_CAP) {
> > +      if (lcladv & ADVERTISE_PAUSE_ASYM) {
> > +         if (rmtadv & LPA_PAUSE_CAP)
> > +            cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
> > +         else if (rmtadv & LPA_PAUSE_ASYM)
> > +            cap = FLOW_CTRL_RX;
> > +      } else {
> > +         if (rmtadv & LPA_PAUSE_CAP)
> > +            cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
> > +      }
> > +   } else if (lcladv & ADVERTISE_PAUSE_ASYM) {
> > +      if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
> > +         cap = FLOW_CTRL_TX;
> > +   }
> > +
> > +   return cap;
> > +}
> 
> There's a rather more elegant way to write this, which is:
> 
>    if (lcladv & rmtadv & ADVERTISE_PAUSE_CAP) {
>       cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
>    } else if (lcladv & rmtadv & ADVERTISE_PAUSE_ASYM) {
>       if (lcladv & ADVERTISE_PAUSE_CAP)
>          cap = FLOW_CTRL_RX;
>       else if (rmtadv & ADVERTISE_PAUSE_CAP)
>          cap = FLOW_CTRL_TX;
>    }
> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.

