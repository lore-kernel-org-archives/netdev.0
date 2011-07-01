From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC patch net-next-2.6] net: allow multiple rx_handler
 registration
Date: Fri, 1 Jul 2011 19:08:50 +0200
Message-ID: <20110701170850.GF2613105@jupiter.n2.diac24.net>
References: <1309447009-8898-1-git-send-email-jpirko@redhat.com>
 <20110630092712.17eb292f@nehalam.ftrdhcpuser.net>
 <20110630172257.GB2056@minipsycho>
 <BANLkTik6mj=8zvYPN-NNvHP-GPcTNHo31Q@mail.gmail.com>
 <4E0DE043.4030701@gmail.com>
 <BANLkTi=j03qATuV+a9OHnjcGsK6kB4zo6Q@mail.gmail.com>
 <4E0DF9C6.703@gmail.com>
 <4E0DFA7F.20005@candelatech.com>
 <4E0DFCC1.1050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?utf-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:33292 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755276Ab1GARJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 13:09:02 -0400
Content-Disposition: inline
In-Reply-To: <4E0DFCC1.1050409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 06:58:41PM +0200, Nicolas de Peslo=C3=BCan wrot=
e:
> Le 01/07/2011 18:49, Ben Greear a =C3=A9crit :
> > On 07/01/2011 09:45 AM, Nicolas de Peslo=C3=BCan wrote:
> >> Le 01/07/2011 17:01, Micha=C5=82 Miros=C5=82aw a =C3=A9crit :
[...]
> >> eth0 - Get everything, untouched. (I know several people except ta=
gged
> >> packets to be untagged here, but I disagree with this part. eth0 i=
s the
> >> raw device and should deliver raw packets, possibly retagging pack=
ets
> >> that were untagged by hw-accel).
> >> eth0.100 - Get VLAN 100 packet, untagged.
> >> eth0.untagged - Get only non-tagged packets, untouched.
> >> eth0.unmatched - Get only tagged packets, untouched.
> >
> > Lets let the current vlan tagging changes settle a while before
> > adding yet more cruft in this area.
>=20
> Agreed.

I also agree that this should sleep for a bit, I do however see a
different use: adding a device to multiple bridges.

(this kinda obviously needs a dynamic priority)

Bridges can filter their RX on everything ebtables can match, they can
even strip off VLAN tags and become "super-VLAN" devices, if you want
that. (Can't access the stripped tag though... but what isn't can
come...)

=46or macvlan/macvtap tbh i try to abstain from using them. Whatever
performance gains/... they give, a setup like
   (eth0-<br0>-veth0)...veth1/tap1=20
appears much cleaner to me.


-David

