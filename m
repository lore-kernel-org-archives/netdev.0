From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 18:35:01 +0200
Message-ID: <20080531163501.GB22607@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu> <20080531060947.GA26441@elte.hu> <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi> <20080531125428.GA22111@elte.hu> <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56977 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950AbYEaQfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 12:35:46 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> > what is the easiest way to figure out whether my version of distcc=20
> > enables TCP_DEFER_ACCEPT?
>=20
> strace distccd (the listening party is the interesting one here, not=20
> the distcc)?
>=20
> ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, sizeof(val))=
=20
> seems to be the magic trick that is interestion here.

seems to be used:

 22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) =3D 62
 22003 listen(4, 10)                     =3D 0
 22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) =3D 0

i'll queue up your reverts for testing in -tip.

	Ingo
