From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sun, 24 Jul 2011 20:26:20 -0700
Message-ID: <20110724202620.1456e742@nehalam.ftrdhcpuser.net>
References: <20110719180222.GA7509@midget.suse.cz>
	<20110722.010628.1678943945721626312.davem@davemloft.net>
	<20110722092159.GA20722@gondor.apana.org.au>
	<4E2ADB39.9070409@gmail.com>
	<20110723152724.GA11028@gondor.apana.org.au>
	<20110723093743.7c90b78f@nehalam.ftrdhcpuser.net>
	<20110724001816.GA14051@gondor.apana.org.au>
	<4E2BD96E.4090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jbohac@suse.cz,
	netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47695 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582Ab1GYD0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 23:26:15 -0400
In-Reply-To: <4E2BD96E.4090101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Jul 2011 10:35:58 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 24/07/2011 02:18, Herbert Xu a =E9crit :
> > On Sat, Jul 23, 2011 at 09:37:43AM -0700, Stephen Hemminger wrote:
> >>
> >> Would it be possible to do live migration without dropping carrier
> >> or setting interface down?
> >
> > I think LM uses the same mechanism as suspend and resume so whateve=
r
> > happens in one case will happen in the other case as well.
>=20
> So we need to distinguish between two kind of link events:
>=20
> 1/ Really having the link goes down then up. This should trigger a re=
negotiation.
>=20
> 2/ Having the system suspend then resume :
> 2a/ This should trigger link down/link up events to force a renegotia=
tion, for normal suspend/resume=20
> where the network might have changed between suspend and resume.
> 2/ This should *not* trigger link down/link up events to avoid a rene=
gotiation (for live migration)=20
> because it is assumed that the network didn't change while suspended.
>=20
> Can't we allow the user to set a global "link-down-link-up-timeout" a=
nd only force a renegotiation=20
> if the time between link down and link up events is longer than this =
timeout? Normal user would set=20
> this timeout close to 0 (default value). Live migration user would se=
t this timeout to about twice=20
> the time it normally takes to do a live migration. That way, in a VM =
environment, if the=20
> suspend/resume cycle happens to take far more than a normal live migr=
ation time, the kernel would=20
> renegotiate, which sounds reasonable, from my point of view.

I hate building infrastructure where it is not needed.

Since virtual machines should be using virtio network devices, shouldn'=
t
the suspend/resume in that device just work. It doesn't need to drop th=
e link.



