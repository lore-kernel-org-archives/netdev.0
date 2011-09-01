From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Thu, 1 Sep 2011 07:46:16 +0200
Message-ID: <20110901054616.GB1969@minipsycho>
References: <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
 <20110831082655.GB2010@minipsycho.brq.redhat.com>
 <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>
 <20110831084511.GD2010@minipsycho.brq.redhat.com>
 <4E5E939C.5000009@gmail.com>
 <1314821537.3274.24.camel@bwh-desktop>
 <4E5E9A30.1040105@gmail.com>
 <4E5E9E16.6060502@candelatech.com>
 <1314826605.3274.34.camel@bwh-desktop>
 <20110831144023.6361de56@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ben Greear <greearb@candelatech.com>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286Ab1IAFqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 01:46:20 -0400
Content-Disposition: inline
In-Reply-To: <20110831144023.6361de56@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2011 at 11:40:23PM CEST, shemminger@vyatta.com wrote:
>On Wed, 31 Aug 2011 22:36:45 +0100
>Ben Hutchings <bhutchings@solarflare.com> wrote:
>
>> On Wed, 2011-08-31 at 13:48 -0700, Ben Greear wrote:
>> > On 08/31/2011 01:31 PM, Nicolas de Peslo=FCan wrote:
>> > > Le 31/08/2011 22:12, Ben Hutchings a =E9crit :
>> > >> On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=FCan wrote:
>> > >>> Le 31/08/2011 10:45, Jiri Pirko a =E9crit :
>> > >>>
>> > >>>>>>> Do you expect drivers using implementation different than =
just calling
>> > >>>>>>> netif_carrier_on/off? Or is it supposed to also e.g. power=
 down PHYs?
>> > >>>>>> Yes, generally it can be used also for en/disable phy, for =
testing
>> > >>>>>> purposes if hw and driver would support it.
>> > >>>>>
>> > >>>>> I'd like to see this working for GRE tunnel devices (for kee=
palive
>> > >>>>> daemon to be able to indicate to routing daemons whether tun=
nel is
>> > >>>>> really working) - implementation would be identical to dummy=
's case.
>> > >>>>> Should I prepare a patch or can I leave it to you?
>> > >>>>
>> > >>>> Ok, I can include it to this patchset (I'm going to repost fi=
rst patch
>> > >>>> anyway)
>> > >>>
>> > >>> Can't we assume that the dummy's case is the default behavior =
and
>> > >>> register this default
>> > >>> ndo_change_carrier callback for every device ?
>> > >>
>> > >> You have got to be joking. No device driver that has real link
>> > >> monitoring should use this implementation.
>> > >
>> > > Well, why not? Arguably, this is probably not the feature one wo=
uld use every day, but...
>> > >
>> > > Testing a cluster reaction to a link down event would be easier =
if one doesn't need to unplug the cable for the test. I understand that=
 one can turn off the
>> > > switch port (physical or virtual), but echo 0 > /sys/class/net/e=
th0/carrier would be nice too.
>> >=20
>> > There is special hardware out there that can do bypass, and often =
it also has a mode
>> > that will programatically cut link by throwing some relays.  We us=
e this for our
>> > testing equipment...
>> >=20
>> > If there is some way to twiddle standard-ish hardware to actually =
drop link, that
>> > would be neat.  I'd think it should be an ethtool type of thing, h=
owever.
>>=20
>> We need to be able to control this as part of our driver test suite =
(on
>> the peer, not the device under test).  There are various MDIO bits t=
hat
>> look like they should do this but unfortunately they don't have
>> consistent effects.  Besides that, many PHYs are not MDIO-manageable=
=2E
>> So this would have to be a device-specific operation, whether it's
>> exposed through ethtool or sysfs.
>>=20
>> > Actually dropping link, and letting that naturally propagate up th=
e stack seems
>> > more reasonable than lying about the status half way up the stack.
>>=20
>
>For testing clustering, there are hooks in vmware and QEMU/KVM to allo=
w
>dropping carrier on the VM side.

Afaik in kvm this is only possible on emulated e1000 (last time I
checked).
