From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Mon, 11 Apr 2011 19:58:23 +0200
Message-ID: <20110411175823.GA31338@rere.qmqm.pl>
References: <20110410131321.8CD9713A64@rere.qmqm.pl> <20110410115302.450794c7@nehalam> <20110411005100.GA22103@rere.qmqm.pl> <20110411075829.7b9bf1e5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57521 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849Ab1DKR60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 13:58:26 -0400
Content-Disposition: inline
In-Reply-To: <20110411075829.7b9bf1e5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 07:58:29AM -0700, Stephen Hemminger wrote:
> On Mon, 11 Apr 2011 02:51:00 +0200
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
>=20
> > On Sun, Apr 10, 2011 at 11:53:02AM -0700, Stephen Hemminger wrote:
> > > On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
> > > Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > > > Caveats:
> > > >  - driver modifies vlan_features on HW VLAN TX changes
> > > >  - broken RX checksum will be reenabled on features change
> > > To be more precise. This is acceptable if and only if all cases
> > > where features are disabled in response to MTU and chip versions
> > > are exactly the same. We don't want to let some user stumble upon
> > > cases where hardware features don't work in their configuration.
> > I was referring to the unlikely case detected by sky2_rx_checksum()=
=2E
> > Before this conversion, user could reenable the feature using ethto=
ol.
> > The change is that now, in this case, it's reenabled also when othe=
r
> > features are changed (i.e. whenever netdev_update_features() gets c=
alled).
>=20
> Ok.
>=20
> It does expose a pre-existing issue. If this logic trips (and I have
> gotten reports of it happening), then the GRO will not get disabled.
> Probably need to mask of GRO as well, since GRO depends on RXCSUM.

This is not a problem, since the code checks skb->ip_summed for protoco=
ls
that implement GRO. See tcp4_gro_receive() for example. This might be
a slight hit in performance, though.

Best Regards,
Micha=B3 Miros=B3aw
