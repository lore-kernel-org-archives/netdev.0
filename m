From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Wed, 10 Sep 2008 09:47:36 -0700
Message-ID: <200809100947.36480.david-b@pacbell.net>
References: <OF26A16F1A.7E5C696A-ON802574BF.003B849F-802574C0.002D5A79@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Catalin Marinas <catalin.marinas@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:43555 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751148AbYIJQrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 12:47:39 -0400
In-Reply-To: <OF26A16F1A.7E5C696A-ON802574BF.003B849F-802574C0.002D5A79@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 September 2008, Steve.Glendinning@smsc.com wrote:
>=20
> > Standard feedback for such stuff:
> >=20
> > =A0- avoid printk() for diagnostics, use dev_*() driver model calls
> > =A0- ... or in this case, pr_warning() if you really must
> > =A0- provide better messages and avoid passing __func__=20
> > =A0- use inline functions instead of CPP macros
> > =A0- make dead code elimination remove debug code, not #ifdefs
> >=20
> > And specific to network devices:
> >=20
> > =A0- use the ethtool message level flags not private debug_mode
>=20
> There's quite a bit of variation on the debugging style across existi=
ng=20
> drivers. =A0Is there any driver you would suggest to use as an exampl=
e of=20
> how to do things right?

Not without searching through a lot of code ... though you
can have a look at <linux/devices.h> dev_dbg() to see how
to use inlines to make sure diagnostic code always gets
type checked and make dead code elimination behave.

So then it'd be "if (netif_msg_FOO(...)) dev_dbg(...)" for
debug messages; or pr_debug; etc.  The thing that's truly
bad about most printk/pr_* type diagnostics is that they
usually don't identify the relevant device, or if they do
then it's not done consistently.

Last time I did a network driver I found that I only wanted
to use those driver model calls before the network device
was set up ... a message tagged with the interface name was
a lot more useful than one tagged with the physical device,
so long as there was an initial banner coupling the two (a
dev_info message printing the interface name along with a
hardware summary).

- Dave
