From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Thu, 8 Jan 2009 11:54:51 -0800
Message-ID: <20090108115451.0b0b854e@extreme>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
	<20081229214101.4c4f5ac1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
	<495BFEAF.6000006@haveacry.com>
	<20090102083402.GA24383@gondor.apana.org.au>
	<4961ECD2.1000502@haveacry.com>
	<20090107041732.GA22041@gondor.apana.org.au>
	<4964B303.4020708@haveacry.com>
	<20090108030745.GA1204@gondor.apana.org.au>
	<4966160A.20001@haveacry.com>
	<20090108083753.14670943@extreme>
	<Pine.LNX.4.64.0901082138060.31441@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Speedster <speedster@haveacry.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59059 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbZAHTyy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:54:54 -0500
In-Reply-To: <Pine.LNX.4.64.0901082138060.31441@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jan 2009 21:39:30 +0200 (EET)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Thu, 8 Jan 2009, Stephen Hemminger wrote:
>=20
> > On Fri, 09 Jan 2009 00:04:42 +0900
> > Speedster <speedster@haveacry.com> wrote:
> >=20
> > > Herbert Xu wrote:
> > > >=20
> > > > Can you please take a look at /proc/net/snmp on the host and th=
e
> > > > guest to see if IP InDiscards is non-zero?
> > >=20
> > > Both are 0
> > >=20
> > > > Also now that we know the problem is definitely in the host/gue=
st
> > > > please take another set of dumps on the interfaces leading to a=
nd
> > > > within the guest to see exactly which path of the system is dro=
pping
> > > > the reply.
> > >=20
> > > Attached (all are the exact same attempted connection), and revea=
l some=20
> > > interesting information.
> > >=20
> > > The path the inbound traffic should take is
> > > 1. vlan50 (host)
> > > 2. tap interface vnet3 (host) / eth0 (guest)
> > > 3. ppp0 (guest)
> > >=20
> > > It looks as though when it is sent out the tap interface the payl=
oad=20
> > > length is incorrect in the PPPoE section of the frame. When it ar=
rives=20
> > > via vlan50 it appears fine. Or at least that's what wireshark hig=
hlights=20
> > > for me :)
> >=20
> > Maybe there is an issue that GRO receive isn't handling padding
> > properly?
>=20
> Hmm, is gro supposed to have something to do with 2.6.27??? Or are yo=
u=20
> talking something else than Herbert's recent GRO stuff?

Trying to find a common thread of why splice and TCP is having
issues in some cases.
