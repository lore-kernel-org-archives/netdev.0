From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 23:00:21 +0200
Message-ID: <20110714210021.GE16759@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
 <aa24cb5cdd3bd082d038960efd7d5c9a2ba95d8e.1310601401.git.mirq-linux@rere.qmqm.pl>
 <1310603009.2756.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48817 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140Ab1GNVAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 17:00:22 -0400
Content-Disposition: inline
In-Reply-To: <1310603009.2756.8.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2011 at 01:23:29AM +0100, Ben Hutchings wrote:
> On Thu, 2011-07-14 at 02:10 +0200, Micha=B3 Miros=B3aw wrote:
> > There are no explicit users, so this is now equivalent to NETIF_F_H=
W_CSUM.
> [...]
> I think this is still a useful distinction, even the networking core
> currently doesn't care about the difference.

The problem is that all packets now can be redirected from NO_CSUM devi=
ce
to other (or userspace). If some protocols just ignore checksum marking
altogether (like SCTP was doing) because of this flag, you get broken
packets that are hard to debug. It costs little to stay on the safe sid=
e
and calculate this additional u32 with checksum information, even if it
stays unused most of the time.

That's why I propose to remove NO_CSUM flag - to prevent someone to wri=
te
such a quietly broken code in the future.

Best Regards,
Micha=B3 Miros=B3aw
