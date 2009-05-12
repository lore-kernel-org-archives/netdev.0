From: Dan Williams <dcbw@redhat.com>
Subject: Re: [Announce] Intel and Nokia announce open source telephony
 project (oFono)
Date: Mon, 11 May 2009 20:54:32 -0400
Message-ID: <1242089672.8166.30.camel@localhost.localdomain>
References: <1242066878.22268.8.camel@little.research.nokia.com>
	 <1242075055.18723.49.camel@localhost.localdomain>
	 <1242075934.2812.3.camel@localhost.localdomain>
	 <1242081534.24094.13.camel@localhost.localdomain>
	 <1242084176.2812.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Aki Niemi <aki.niemi@nokia.com>, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43335 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587AbZELAxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 20:53:38 -0400
In-Reply-To: <1242084176.2812.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 16:22 -0700, Marcel Holtmann wrote:
> Hi Dan,
> 
> > > > > Intel and Nokia are pleased to jointly announce the oFono project
> > > > > (http://ofono.org), an open source project for developing an open source
> > > > > telephony solution.
> > > > > 
> > > > > oFono.org is a place to bring developers together around designing an
> > > > > infrastructure for building mobile telephony (GSM/UMTS) applications.
> > > > > oFono.org is licensed under GPLv2, and it includes a high-level D-Bus
> > > > > API for use by telephony applications of any license.  oFono.org also
> > > > > includes a low-level plug-in API for integrating with Open Source as
> > > > > well as third party telephony stacks, cellular modems and storage
> > > > > back-ends.  The plug-in API functionality is modeled on public
> > > > > standards, in particular 3GPP TS 27.007 "AT command set for User
> > > > > Equipment (UE)."
> > > > > 
> > > > > Source code is available on http://ofono.org/downloads and a high-level
> > > > > architecture diagram is available on http://ofono.org/documentation.  To
> > > > > join the mailing list, go to http://lists.ofono.org/listinfo/ofono.
> > > > > 
> > > > > Nokia and Intel will jointly maintain the oFono project.  We'd like to
> > > > > invite all developers to join the oFono.org effort and community.
> > > > 
> > > > So a few questions...
> > > > 
> > > > - Where's the IS-707/IS-856 support?  Yes, many operators will be
> > > > transitioning to LTE by 2015, but there are 450 million CDMA subscribers
> > > > right now [1], and that number is expected to grow.  Having two modem
> > > > control stacks simply isn't an option.  Not having designed support for
> > > > CDMA into the service seems pretty short-sighted.  I know Nokia itself
> > > > doesn't care about CDMA any more, but still...
> > > 
> > > we did talk about CDMA voice support and so far nobody of us had good
> > > enough experience with how it works on the voice level. Let me assure
> > > you that we wanna definitely allow support for it.
> > 
> > I meant data, not voice...  What I'd like to know (and I couldn't find
> > out from looking for the introspection data, or missing API
> > specification) is whether you've made provisions for CDMA devices in the
> > D-Bus API.
> 
> so far not much time has been spent to integrate the data part. We are
> concentrating on getting voice going.
> 
> We want CDMA support for voice and data, but as I said, most of us are
> not using that technology on a regular basis. We haven't forgotten about
> it though :)
> 
> > > > - GPS support?  In reality, there can only be one service arbitrating
> > > > access to modem serial ports, since not all serial-based modems provide
> > > > more than two ports, and one of those must be used for PPP, and the
> > > > other for signal strength, etc.  Logically, the service controlling
> > > > these ports for cellular should also be handling GPS requests on these
> > > > devices.
> > > 
> > > I talked with our designers and engineers about it and we do see the
> > > need to handle this properly for modem devices where the control part is
> > > the same for the modem. We need to figure out on how to integrate this
> > > properly with Gypsy. Advantage of oFono is that it has a generic plugin
> > > infrastructure.
> > 
> > I'd expect services like ModemManager or ofono to implement a standard
> > GPS D-Bus interface that consumers of GPS information could query as
> > long as they are pointed at the right bus name.  GPS queries are
> > specific to the modem in question.
> 
> It is not that simple. Let me ensure you that I am aware of this mess
> with mixing GPS and modem hardware and their control endpoints. For us
> the Gypsy has the better interfaces in conjunction with GeoClue.
> 
> On a side note here. We also wanna support proper cell tower
> triangulation for location based services.
> 
> > > > - Is there some reason we cannot coalesce around *one* userland cellular
> > > > service?  There's Wader/VMC (python+dbus) and ModemManager (C+dbus) and
> > > > gsmd (C+dbus) already; it seems that for the sake of users, it would be
> > > > great to concentrate that effort in *one* place so that we don't have to
> > > > keep quirking every single modem in 4 different places.  TBH, I don't
> > > > care which one it is, as long as (a) it has a sane D-Bus interface, (b)
> > > > it supports CDMA, (c) it uses DeviceKit, and (d) it's GPLv2.
> > > 
> > > I think that the basic modem detection/quirking has to be done with your
> > > modem id tool from udev-extras.
> > 
> > I think you misunderstand the scope of modem quirking.  Please read
> > something like:
> > 
> > http://blogs.gnome.org/dcbw/2009/03/20/thats-when-i-reach-for-my-revolver/
> > 
> > There are like 5 different ways to specify 2G/3G preference; and while
> > having a plugin system is nice and solves it for a *single* modem
> > manager, the question I was asking was why we cannot all work on a
> > single modem manager service and do all this hardware support in one
> > place.
> > 
> > The situation we have now is like Linux vs. Solaris vs NetBSD vs
> > FreeBSD.  All can drive the same hardware, but you have to write support
> > for the same hardware in each different OS, though copy & paste helps
> > between the BSDs at least.
> > 
> > Why have to duplicate hardware support in 4 different places?  Why can
> > we not coalesce around one stack?  Why write a different stack when
> > there are existing ones that already work, where the voice support could
> > have been added?
> 
> We are currently deriving from voice features and there was nothing that
> satisfied us. Especially when it comes to support fully non AT modem
> drivers. Cellphones do use special cellular modem protocols. For example
> the ones from Nokia.

Right, so why couldn't Phonenet support be added to something like
ModemManager, which also uses a plugin-based infrastructure and does not
expose AT stuff over the D-Bus interface?

What we have here is a huge duplication of effort, yet again.

Dan

