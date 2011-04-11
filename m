From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Mon, 11 Apr 2011 11:09:19 -0700
Message-ID: <20110411110919.73234f67@nehalam>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
	<20110410115302.450794c7@nehalam>
	<20110411005100.GA22103@rere.qmqm.pl>
	<20110411075829.7b9bf1e5@nehalam>
	<20110411175823.GA31338@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51617 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752606Ab1DKSJZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 14:09:25 -0400
In-Reply-To: <20110411175823.GA31338@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2011 19:58:23 +0200
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> On Mon, Apr 11, 2011 at 07:58:29AM -0700, Stephen Hemminger wrote:
> > On Mon, 11 Apr 2011 02:51:00 +0200
> > Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
> >=20
> > > On Sun, Apr 10, 2011 at 11:53:02AM -0700, Stephen Hemminger wrote=
:
> > > > On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
> > > > Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
> > > > > Caveats:
> > > > >  - driver modifies vlan_features on HW VLAN TX changes
> > > > >  - broken RX checksum will be reenabled on features change
> > > > To be more precise. This is acceptable if and only if all cases
> > > > where features are disabled in response to MTU and chip version=
s
> > > > are exactly the same. We don't want to let some user stumble up=
on
> > > > cases where hardware features don't work in their configuration=
=2E
> > > I was referring to the unlikely case detected by sky2_rx_checksum=
().
> > > Before this conversion, user could reenable the feature using eth=
tool.
> > > The change is that now, in this case, it's reenabled also when ot=
her
> > > features are changed (i.e. whenever netdev_update_features() gets=
 called).
> >=20
> > Ok.
> >=20
> > It does expose a pre-existing issue. If this logic trips (and I hav=
e
> > gotten reports of it happening), then the GRO will not get disabled=
=2E
> > Probably need to mask of GRO as well, since GRO depends on RXCSUM.
>=20
> This is not a problem, since the code checks skb->ip_summed for proto=
cols
> that implement GRO. See tcp4_gro_receive() for example. This might be
> a slight hit in performance, though.

The performance hit is expected, just thought that GRO depended on rx c=
hecksum.
