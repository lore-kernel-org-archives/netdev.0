From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [Announce] Intel and Nokia announce open source telephony
 project (oFono)
Date: Mon, 11 May 2009 14:05:34 -0700
Message-ID: <1242075934.2812.3.camel@localhost.localdomain>
References: <1242066878.22268.8.camel@little.research.nokia.com>
	 <1242075055.18723.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Aki Niemi <aki.niemi@nokia.com>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57548 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbZEKVGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 17:06:03 -0400
In-Reply-To: <1242075055.18723.49.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> > Intel and Nokia are pleased to jointly announce the oFono project
> > (http://ofono.org), an open source project for developing an open source
> > telephony solution.
> > 
> > oFono.org is a place to bring developers together around designing an
> > infrastructure for building mobile telephony (GSM/UMTS) applications.
> > oFono.org is licensed under GPLv2, and it includes a high-level D-Bus
> > API for use by telephony applications of any license.  oFono.org also
> > includes a low-level plug-in API for integrating with Open Source as
> > well as third party telephony stacks, cellular modems and storage
> > back-ends.  The plug-in API functionality is modeled on public
> > standards, in particular 3GPP TS 27.007 "AT command set for User
> > Equipment (UE)."
> > 
> > Source code is available on http://ofono.org/downloads and a high-level
> > architecture diagram is available on http://ofono.org/documentation.  To
> > join the mailing list, go to http://lists.ofono.org/listinfo/ofono.
> > 
> > Nokia and Intel will jointly maintain the oFono project.  We'd like to
> > invite all developers to join the oFono.org effort and community.
> 
> So a few questions...
> 
> - Where's the IS-707/IS-856 support?  Yes, many operators will be
> transitioning to LTE by 2015, but there are 450 million CDMA subscribers
> right now [1], and that number is expected to grow.  Having two modem
> control stacks simply isn't an option.  Not having designed support for
> CDMA into the service seems pretty short-sighted.  I know Nokia itself
> doesn't care about CDMA any more, but still...

we did talk about CDMA voice support and so far nobody of us had good
enough experience with how it works on the voice level. Let me assure
you that we wanna definitely allow support for it.

> - GPS support?  In reality, there can only be one service arbitrating
> access to modem serial ports, since not all serial-based modems provide
> more than two ports, and one of those must be used for PPP, and the
> other for signal strength, etc.  Logically, the service controlling
> these ports for cellular should also be handling GPS requests on these
> devices.

I talked with our designers and engineers about it and we do see the
need to handle this properly for modem devices where the control part is
the same for the modem. We need to figure out on how to integrate this
properly with Gypsy. Advantage of oFono is that it has a generic plugin
infrastructure.

> - Is there some reason we cannot coalesce around *one* userland cellular
> service?  There's Wader/VMC (python+dbus) and ModemManager (C+dbus) and
> gsmd (C+dbus) already; it seems that for the sake of users, it would be
> great to concentrate that effort in *one* place so that we don't have to
> keep quirking every single modem in 4 different places.  TBH, I don't
> care which one it is, as long as (a) it has a sane D-Bus interface, (b)
> it supports CDMA, (c) it uses DeviceKit, and (d) it's GPLv2.

I think that the basic modem detection/quirking has to be done with your
modem id tool from udev-extras.

Please keep in mind that oFono is also for voice call features and hence
has to integrate native with BlueZ and PulseAudio. We wanna create a
full features open source telephony stack.

Regards

Marcel


