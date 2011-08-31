From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 22:36:45 +0100
Message-ID: <1314826605.3274.34.camel@bwh-desktop>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
	 <1314715608-978-2-git-send-email-jpirko@redhat.com>
	 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
	 <20110831082655.GB2010@minipsycho.brq.redhat.com>
	 <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>
	 <20110831084511.GD2010@minipsycho.brq.redhat.com>
	 <4E5E939C.5000009@gmail.com> <1314821537.3274.24.camel@bwh-desktop>
	 <4E5E9A30.1040105@gmail.com>  <4E5E9E16.6060502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8410 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815Ab1HaVgx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 17:36:53 -0400
In-Reply-To: <4E5E9E16.6060502@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 13:48 -0700, Ben Greear wrote:
> On 08/31/2011 01:31 PM, Nicolas de Peslo=C3=BCan wrote:
> > Le 31/08/2011 22:12, Ben Hutchings a =C3=A9crit :
> >> On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=C3=BCan wrote:
> >>> Le 31/08/2011 10:45, Jiri Pirko a =C3=A9crit :
> >>>
> >>>>>>> Do you expect drivers using implementation different than jus=
t calling
> >>>>>>> netif_carrier_on/off? Or is it supposed to also e.g. power do=
wn PHYs?
> >>>>>> Yes, generally it can be used also for en/disable phy, for tes=
ting
> >>>>>> purposes if hw and driver would support it.
> >>>>>
> >>>>> I'd like to see this working for GRE tunnel devices (for keepal=
ive
> >>>>> daemon to be able to indicate to routing daemons whether tunnel=
 is
> >>>>> really working) - implementation would be identical to dummy's =
case.
> >>>>> Should I prepare a patch or can I leave it to you?
> >>>>
> >>>> Ok, I can include it to this patchset (I'm going to repost first=
 patch
> >>>> anyway)
> >>>
> >>> Can't we assume that the dummy's case is the default behavior and
> >>> register this default
> >>> ndo_change_carrier callback for every device ?
> >>
> >> You have got to be joking. No device driver that has real link
> >> monitoring should use this implementation.
> >
> > Well, why not? Arguably, this is probably not the feature one would=
 use every day, but...
> >
> > Testing a cluster reaction to a link down event would be easier if =
one doesn't need to unplug the cable for the test. I understand that on=
e can turn off the
> > switch port (physical or virtual), but echo 0 > /sys/class/net/eth0=
/carrier would be nice too.
>=20
> There is special hardware out there that can do bypass, and often it =
also has a mode
> that will programatically cut link by throwing some relays.  We use t=
his for our
> testing equipment...
>=20
> If there is some way to twiddle standard-ish hardware to actually dro=
p link, that
> would be neat.  I'd think it should be an ethtool type of thing, howe=
ver.

We need to be able to control this as part of our driver test suite (on
the peer, not the device under test).  There are various MDIO bits that
look like they should do this but unfortunately they don't have
consistent effects.  Besides that, many PHYs are not MDIO-manageable.
So this would have to be a device-specific operation, whether it's
exposed through ethtool or sysfs.

> Actually dropping link, and letting that naturally propagate up the s=
tack seems
> more reasonable than lying about the status half way up the stack.

Right.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
