From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Mon, 20 May 2013 21:37:11 +0100
Message-ID: <1369082231.4616.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	 <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
	 <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
	 <CAJZOPZ+c4HDbd+983qosp+NOmpZ-U3sCWKyKZrEVW_UDhfMEWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <ronye@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33337 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756916Ab3ETUhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:37:15 -0400
In-Reply-To: <CAJZOPZ+c4HDbd+983qosp+NOmpZ-U3sCWKyKZrEVW_UDhfMEWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-20 at 23:06 +0300, Or Gerlitz wrote:
> On Fri, May 10, 2013 at 3:34 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > Yeah.  In some ways it could be better for a PF driver to create two net
> > devices, one which acts as a vswitch port and one which bypasses it (if
> > possible).  But then that's going to confuse people too.  I don't think we can win...
> 
> >>> Perhaps the default should also be specified?
> 
> 
> So can we make progress in steps here... e.g deal with the question
> whether the PF exposes one or two netdevices in a future thread

Definitely, I don't want to derail your proposal.

> and
> add now code supporting an admin ability to control VF link state (I
> suggest for the default, e.g when no config directive was applied to
> be "auto" means follow the PF link state, as was suggested here)?

I think that's a sensible default.

> if
> we agree on that, do we want new ndo_set_vf_ call or introducr
> ndo_set_vf_config call which whose param will be further extended each
> time we add new feature to control/configure?

The risk I see with extensible operations (and which has occurred with
many ethtool operations) is that drivers may quietly ignore the elements
they don't implement.  So either (1) add yet another specific operation
or (2) define a general VF setter, require drivers to set some flags
that indicate which VF attributes are settable, and check the flags in
rtnetlink.c before calling into the driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
