From: Soeren Sonnenburg <kernel@nn7.de>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
	tcp_mark_head_lost+0x11d/0x150()
Date: Sat, 05 Apr 2008 18:40:34 +0200
Message-ID: <1207413634.4597.4.camel@localhost>
References: <1207199456.7616.3.camel@localhost>
	 <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
	 <1207230008.4513.14.camel@localhost>
	 <Pine.LNX.4.64.0804031744190.32094@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nn7.de ([85.214.94.156]:44482 "EHLO nn7.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbYDEQlA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 12:41:00 -0400
In-Reply-To: <Pine.LNX.4.64.0804031744190.32094@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-04-04 at 21:51 +0300, Ilpo J=E4rvinen wrote:
> On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
>=20
> > On Thu, 2008-04-03 at 16:26 +0300, Ilpo J=E4rvinen wrote:
> > > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > >=20
> > > > trying to download things, I am seeing this (ignore the tainted=
, it is
> > > > from madwifi and although the module is loaded the device was n=
ever
> > > > used)
> > > >=20
> > > > Could anyone make sense of this please?
> > >=20
> > > ...I'm just trying to find out who and where invariants of the TC=
P code
> > > are broken. These were relatively recently enabled (pre-2.6.24 ju=
st didn't=20
> > > care too much). A number of long standing issues plus bugs from m=
y=20
> > > modifications have been fixed because of the more rigid checking =
:-).
> > >=20
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/=
0x150()
> > >=20
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x27=
0()
> > >=20
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()
> > >=20
> > > Can you reproduce it?=20
> >=20
> > Yes, by massively downloading things :-) But I have no real recipe =
to
> > make it easily reproducible...
>=20
> Good :-), no need for recipes, just that you can trigger it more ofte=
n=20
> tha once per month or so :-). I probably couldn't trigger it anyway h=
ere=20
> because they're often rather sensitive to network "weather", thus if =
you=20
> have problems in reproducing, doing tests around the same phase of th=
e=20
> date cycle you saw it the first time might help.
>=20
> Here's a debug patch which expensively verifies TCP's state in a numb=
er
> of places during ACK to find first spot where the actual bug occurs.

OK I am getting this now as the first spot:

P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
skb 0 f495c180
skb 1 f480a180
skb 2 f4994600
head 3 f495c780
skb 4 f5b32480
TCP wq(s) LL  <
WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()

another one:
WARNING: at net/ipv4/tcp_output.c:1475 __tcp_push_pending_frames+0x70/0=
x830()


P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
skb 0 f495c180
skb 1 f480a180
skb 2 f4994600
head 3 f495c780
skb 4 f5b32480
TCP wq(s) LL  <
TCP wq(h) +-++<
l2 s3 f0 p4 seq: su4023500226 hs241530103 sn4023505874
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()

Soeren
