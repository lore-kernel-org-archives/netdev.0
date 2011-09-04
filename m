From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sat, 3 Sep 2011 21:14:38 -0700
Message-ID: <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
	<4E6272BC.4020707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41762 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793Ab1IDEO2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 00:14:28 -0400
In-Reply-To: <4E6272BC.4020707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Sep 2011 20:32:28 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 03/09/2011 00:11, Stephen Hemminger a =E9crit :
> > On Fri, 02 Sep 2011 23:39:03 +0200
> > Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
> >
> >> Le 02/09/2011 19:22, Stephen Hemminger a =E9crit :
> >>> This resolves a regression seen by some users of bridging.
> >>> Some users use the bridge like a dummy device.
> >>> They expect to be able to put an IPv6 address on the device
> >>> with no ports attached during boot.
> >>>
> >>> Note: the bridge still will reflect the state of ports in the
> >>> bridge if there are any added.
> >>
> >> Doesn't this jeopardize the behavior introduced in 1faa4356a3bd89e=
a11fb92752d897cff3a20ec0e
> >> "bridge: control carrier based on ports online"?
> >>
> >> If the user starts the DHCP client before adding the first port to=
 the bridge, the DHCP client will
> >> have a carrier and start the autoconfiguration process. This was t=
he old behavior, but you fixed it.
> >>
> >> 	Nicolas.
> >>
> >
> > There is no perfect solution.
> > If DHCP works then IPv6 breaks?
>=20
> Instead of asserting carrier when the bridge have no port, can't we a=
ssert carrier when the three=20
> following condition are true at the same time :
>=20
> - The bridge have no port.
> - At least one IP address is setup on the bridge.
> - The two above conditions are true for more than a configurable amou=
nt of seconds, with a default=20
> of 10, for example.
>=20
> This would only delay carrier on for a few seconds for the regression=
 and keep the current behavior=20
> (carrier off until at least 1 port is on) for DHCP.

This fails on two counts:
1. Bridge's often run without IP addresses!
2. DHCP won't try and send out request until carrier is true.
