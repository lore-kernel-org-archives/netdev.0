From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Question about tg3 and bnx2 driver suppliers
Date: Sun, 20 Feb 2011 12:41:15 -0800
Message-ID: <20110220124115.730eca80@nehalam>
References: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
	<1297952255.2604.115.camel@edumazet-laptop>
	<4D615B2D.5080804@neli.hopto.org>
	<1298229420.8559.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Micha Nelissen <micha@neli.hopto.org>,
	Michael Durket <durket@highwire.stanford.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51816 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075Ab1BTUlU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 15:41:20 -0500
In-Reply-To: <1298229420.8559.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Feb 2011 20:17:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le dimanche 20 f=E9vrier 2011 =E0 19:19 +0100, Micha Nelissen a =E9cr=
it :
> > Eric Dumazet wrote:
> > > One possible cause of packet drops is when softirqs are disabled =
for too
> > > long periods, even if NIC has a big RX ring (check ethtool -g eth=
0)
> >=20
> > Why aren't the softirqs converted to workqueues? Wouldn't that cut=20
> > dependencies to other softirq users and improve latency?
> >=20
>=20
> Because it was done like that in the old days.
>=20
> Its a bit less important these days, now typical machines have 8+ cpu=
s.
> Each device interrupt can be handled by its own cpu :)

The latency to schedule a work queue is still much higher
than the latency to do a softirq. Last time I played around with it,
things like loopback performance dropped 10% if using work queue.
