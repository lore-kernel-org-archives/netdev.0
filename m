From: Bill Fink <billfink@mindspring.com>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet
 receive)
Date: Fri, 27 Apr 2007 03:17:57 -0400
Message-ID: <20070427031757.513f6ad7.billfink@mindspring.com>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
	<4630D069.30605@redhat.com>
	<Pine.LNX.4.64.0704262219200.18515@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:48523
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755445AbXD0H1q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 03:27:46 -0400
In-Reply-To: <Pine.LNX.4.64.0704262219200.18515@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Apr 2007, Ilpo J=E4rvinen wrote:

> On Thu, 26 Apr 2007, Chuck Ebbert wrote:
>=20
> > Ilpo J=E4rvinen wrote:
> > > ...I'm unsure how to continue the investigation from this point o=
nward=20
> > > and asking for ideas/suggestions or how to rule out more possibil=
ities...=20
> > > Or is there some knob which I don't know of that should be toggle=
d or=20
> > > something, is 2.6 network stack expected to behave this way?
> > >=20
> >=20
> > Try a different network adapter.
>=20
> Hmm, I thought I had already done this but I just noticed that it is =
so=20
> that the adapter was still the same as the other host has two adapter=
 (now=20
> that I look again). I'll give it a try tomorrow to see if using the=20
> another adapter makes any difference.
>=20
> > Try turning off hardware TSO offload:
> >   ethtool -K ethX tso off
>=20
> # ethtool -K eth0 tso off
> Cannot set device tcp segmentation offload settings: Operation not=20
> supported

Could the delays be caused by Ethernet PAUSE frames (which might not
be rquired at the slower 10FD but might at 100)?  TX and RX pause
control settings (check with "ethtool -a") might be different between
the 2.4 and 2.6 kernels.

Also check things like net.core.netdev_max_backlog and ifconfig
txqueuelen settings.  And check "ethtool -S", "netstat -s", and
ifconfig error counters.

						-Bill
