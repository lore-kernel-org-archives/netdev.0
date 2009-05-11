From: Dan Williams <dcbw@redhat.com>
Subject: Re: [Announce] Intel and Nokia announce open source telephony
 project (oFono)
Date: Mon, 11 May 2009 16:50:55 -0400
Message-ID: <1242075055.18723.49.camel@localhost.localdomain>
References: <1242066878.22268.8.camel@little.research.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>
To: Aki Niemi <aki.niemi@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45699 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757036AbZEKUuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 16:50:04 -0400
In-Reply-To: <1242066878.22268.8.camel@little.research.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 21:34 +0300, Aki Niemi wrote:
> Intel and Nokia are pleased to jointly announce the oFono project
> (http://ofono.org), an open source project for developing an open source
> telephony solution.
> 
> oFono.org is a place to bring developers together around designing an
> infrastructure for building mobile telephony (GSM/UMTS) applications.
> oFono.org is licensed under GPLv2, and it includes a high-level D-Bus
> API for use by telephony applications of any license.  oFono.org also
> includes a low-level plug-in API for integrating with Open Source as
> well as third party telephony stacks, cellular modems and storage
> back-ends.  The plug-in API functionality is modeled on public
> standards, in particular 3GPP TS 27.007 "AT command set for User
> Equipment (UE)."
> 
> Source code is available on http://ofono.org/downloads and a high-level
> architecture diagram is available on http://ofono.org/documentation.  To
> join the mailing list, go to http://lists.ofono.org/listinfo/ofono.
> 
> Nokia and Intel will jointly maintain the oFono project.  We'd like to
> invite all developers to join the oFono.org effort and community.

So a few questions...

- Where's the IS-707/IS-856 support?  Yes, many operators will be
transitioning to LTE by 2015, but there are 450 million CDMA subscribers
right now [1], and that number is expected to grow.  Having two modem
control stacks simply isn't an option.  Not having designed support for
CDMA into the service seems pretty short-sighted.  I know Nokia itself
doesn't care about CDMA any more, but still...

- GPS support?  In reality, there can only be one service arbitrating
access to modem serial ports, since not all serial-based modems provide
more than two ports, and one of those must be used for PPP, and the
other for signal strength, etc.  Logically, the service controlling
these ports for cellular should also be handling GPS requests on these
devices.

- Is there some reason we cannot coalesce around *one* userland cellular
service?  There's Wader/VMC (python+dbus) and ModemManager (C+dbus) and
gsmd (C+dbus) already; it seems that for the sake of users, it would be
great to concentrate that effort in *one* place so that we don't have to
keep quirking every single modem in 4 different places.  TBH, I don't
care which one it is, as long as (a) it has a sane D-Bus interface, (b)
it supports CDMA, (c) it uses DeviceKit, and (d) it's GPLv2.

Dan

[1] http://www.cdg.org/technology/cdma_technology/cdma_stats.asp


