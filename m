From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Fri, 18 Dec 2009 21:09:06 +0100
Message-ID: <20091218200906.GA2604@ami.dom.local>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
 <20091216154713.f082e7cf.akpm@linux-foundation.org>
 <4B2A9A40.90203@freemail.hu>
 <20091217132451.b168a796.akpm@linux-foundation.org>
 <4B2AA64C.50709@gmail.com>
 <4B2B35B7.6060703@freemail.hu>
 <4B2BB27D.5050609@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?iso-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:57307 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbZLRUJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 15:09:35 -0500
Received: by fxm21 with SMTP id 21so3176133fxm.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 12:09:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B2BB27D.5050609@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2009 at 05:49:01PM +0100, N=E9meth M=E1rton wrote:
> N=E9meth M=E1rton worte:
> > I use KDE, and the KNetworkManager icon is visible on the task bar.=
 When
> > I unplug the network cable the "disconnected" icon appears. After I=
 plug the
> > network cable again, a rotating wheel appears. Here comes the diffe=
rence: *when*
> > the rotating wheel changes to "connected" state. One case, when the=
 IP address
> > is kept the "connected" icon appears right after the IP address ass=
igned by
> > DHCP appears in the ifconfig output. In the wrong case this rotatin=
g wheel is
> > still there for about 60 seconds while the the assigned IP address =
is dropped
> > and an IP address like 169.254.123.251 is assigned.
>=20
> I would like to add that with 2.6.32 the IP address is dropped even i=
f I exit
> the KNetworkManager before unplugging the network cable.
>=20
> I can reproduce the problem without touching the network cable. If I =
execute
> (I am running Debian 5.0, kernel 2.6.32):
>=20
> # /etc/init.d/network-manager stop
>=20
> then the network goes down. After this I execute:
>=20
> # /etc/init.d/network-manager start
>=20
> then the network comes up, the IP address assigned by DHCP appears fo=
r about a
> minute then the this IP address is dropped and the address starting w=
ith
> 169.254 is assigned.

Hmm... currently I'm out of new (wrong ;-) ideas. It seems there is
some longer break in (mostly multicast) traffic just before releasing
the DHCP address, according to this wireshark dump. Maybe this network
manager tries reloading to fix something? (Isn't there nothing strange
in logs from this network manager, btw?)

You wrote earlier that you can get it working OK with dhclient, so I
wonder if it's not some userspace (KNetworkManager) incompatibility
with the new kernel (I mean if it works OK with basic dhcp tools
started as root). Could you verify that more?

Regards,
Jarek P.
