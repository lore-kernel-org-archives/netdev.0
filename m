From: Soeren Sonnenburg <kernel@nn7.de>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
	tcp_mark_head_lost+0x11d/0x150()
Date: Sat, 05 Apr 2008 20:14:43 +0200
Message-ID: <1207419283.4597.12.camel@localhost>
References: <1207199456.7616.3.camel@localhost>
	 <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
	 <1207230008.4513.14.camel@localhost>
	 <Pine.LNX.4.64.0804031744190.32094@wrl-59.cs.helsinki.fi>
	 <1207413634.4597.4.camel@localhost>
	 <Pine.LNX.4.64.0804052043230.8668@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nn7.de ([85.214.94.156]:46746 "EHLO nn7.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbYDESPI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 14:15:08 -0400
In-Reply-To: <Pine.LNX.4.64.0804052043230.8668@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-04-05 at 20:52 +0300, Ilpo J=E4rvinen wrote:
> On Sat, 5 Apr 2008, Soeren Sonnenburg wrote:
>=20
> > On Fri, 2008-04-04 at 21:51 +0300, Ilpo J=E4rvinen wrote:
> > > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > >=20
> > > > On Thu, 2008-04-03 at 16:26 +0300, Ilpo J=E4rvinen wrote:
> > > > > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > > > >=20
> > > > > > trying to download things, I am seeing this (ignore the tai=
nted, it is
> > > > > > from madwifi and although the module is loaded the device w=
as never
> > > > > > used)
> > > > > >=20
> > > > > > Could anyone make sense of this please?
[...]
> > >=20
> > > Here's a debug patch which expensively verifies TCP's state in a =
number
> > > of places during ACK to find first spot where the actual bug occu=
rs.
> >=20
> > OK I am getting this now as the first spot:
> >=20
> > P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
> > skb 0 f495c180
> > skb 1 f480a180
> > skb 2 f4994600
> > head 3 f495c780
> > skb 4 f5b32480
> > TCP wq(s) LL  <
> > WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()
> >
> > another one:
> > WARNING: at net/ipv4/tcp_output.c:1475 __tcp_push_pending_frames+0x=
70/0x830()
> >=20
> >=20
> > P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
> > skb 0 f495c180
> > skb 1 f480a180
> > skb 2 f4994600
> > head 3 f495c780
> > skb 4 f5b32480
> > TCP wq(s) LL  <
> > TCP wq(h) +-++<
> > l2 s3 f0 p4 seq: su4023500226 hs241530103 sn4023505874
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()
>=20
> Please don't cut the log! It is caught here because 2+3 > 4 :-) but I=
 need=20
> the full log with stacktraces this time to figure it out.

Look here=20
http://nn7.de/debugging/tcp.log :-)

HTH,
Soeren

