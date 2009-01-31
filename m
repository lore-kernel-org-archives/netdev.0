From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Sat, 31 Jan 2009 11:03:33 -0500
Message-ID: <20090131160333.GC23100@localhost.localdomain>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41432 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbZAaQDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 11:03:37 -0500
Content-Disposition: inline
In-Reply-To: <49838213.90700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
> Kenny Chang a =E9crit :
> > Ah, sorry, here's the test program attached.
> >=20
> > We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or the
> > 2.6.29.-rcX.
> >=20
> > Right now, we are trying to step through the kernel versions until =
we
> > see where the performance drops significantly.  We'll try 2.6.29-rc=
 soon
> > and post the result.
>=20
> 2.6.29-rc contains UDP receive improvements (lockless)
>=20
> Problem is multicast handling was not yet updated, but could be :)
>=20
>=20
> I was asking you "cat /proc/interrupts" because I believe you might
> have a problem NIC interrupts being handled by one CPU only (when hav=
ing problems)
>=20
That would be expected (if irqbalance is running), and desireable, sinc=
e
spreading high volume interrupts like NICS accross multiple cores (or m=
ore
specifically multiple L2 caches), is going increase your cache line mis=
s rate
significantly and decrease rx throughput.

Although you do have a point here, if the system isn't running irqbalan=
ce, and
the NICS irq affinity is spread accross multiple L2 caches, that would =
be a
point of improvement performance-wise. =20

Kenny, if you could provide the /proc/interrupts info along with /proc/=
cpuinfo
and your stats that I asked about earlier, that would be a big help.

Regards
Neil

