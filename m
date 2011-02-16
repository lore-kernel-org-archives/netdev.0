From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5 RESEND 2/9] ethtool: enable GSO and GRO by default
Date: Wed, 16 Feb 2011 03:42:37 +0100
Message-ID: <20110216024237.GA6434@rere.qmqm.pl>
References: <66135e57d38599c0dfce347643858558c4f026c4.1297594674.git.mirq-linux@rere.qmqm.pl> <20110213.105023.68138742.davem@davemloft.net> <20110215214649.GA23866@rere.qmqm.pl> <20110215.140043.59699086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:32789 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596Ab1BPCmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:42:39 -0500
Content-Disposition: inline
In-Reply-To: <20110215.140043.59699086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 15, 2011 at 02:00:43PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Tue, 15 Feb 2011 22:46:49 +0100
> > On Sun, Feb 13, 2011 at 10:50:23AM -0800, David Miller wrote:
> >> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> >> Date: Sun, 13 Feb 2011 12:11:45 +0100 (CET)
> >> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> >> This is not appropriate.
> >>=20
> >> Now, every driver that lacks SG support will spit out that warning
> >> message in netdev_fix_features().
> >>=20
> >> That's why the check is there conditionalizing NETIF_F_GSO on
> >> NETIF_F_SG in register_netdevice().
> > I think all those messages should be converted to DEBUG level. Thos=
e
> > conditions are constant and can be better described in
> > Documentation/networking/ or ethtool manpage. Preferably along the
> > device-specific conditions when implemented.
> >=20
> > Or I could just drop the message for the GSO case as it's something=
 new here
> > anyway (I added it to make it consistent with handling of other fea=
tures).
> The messages exist to let driver authors know they've constructed an
> illegal set of feature bits.

Only multiple checksum flags are actual driver bugs - those are handled
in register_netdevice(). netdev_fix_features() represents limitations o=
f core
networking code . Hardware might as well handle TSO without SG or SG wi=
thout
checksumming. What's the point in duplicating those restrictions in dri=
vers?

> Since you're now adding the GSO bit yourself, you should perform
> due diligence and prevent the illegal combination yourself.
>
> This has no other impact on the other messages and cases, which
> definitely should stay intact.
>=20
> Your change is just wrong and knowingly introduces useless log
> messages, please just fix it up.

The messages from netdev_fix_features() will also be triggered by user
disabling required feature (ie. HW checksum for most of TX offloads)
for a device or its slave or sometimes on MTU changes (ie. for jme and
possibly others).  Even after I fix triggering of "GSO needs SG"
message in register_netdevice(), this and other messages will show up
more often because of the way the new scheme works.

Best Regards,
Micha=B3 Miros=B3aw
