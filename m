From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 15507] New: kernel misses 3rd part of tcp
 handshake (ACK), stays in SYN_RECV state
Date: Fri, 19 Mar 2010 00:12:31 +0100
Message-ID: <1268953951.2894.194.camel@edumazet-laptop>
References: <bug-15507-10286@http.bugzilla.kernel.org/>
	 <20100318160103.cc28c367.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, roysjosh@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:50404 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab0CRXMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:12:36 -0400
Received: by bwz1 with SMTP id 1so2549978bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 16:12:34 -0700 (PDT)
In-Reply-To: <20100318160103.cc28c367.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 mars 2010 =C3=A0 16:01 -0700, Andrew Morton a =C3=A9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Wed, 10 Mar 2010 14:50:51 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > http://bugzilla.kernel.org/show_bug.cgi?id=3D15507
> >=20
> >            Summary: kernel misses 3rd part of tcp handshake (ACK), =
stays
> >                     in SYN_RECV state
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.32.9-67.fc12
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Fedora
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: roysjosh@gmail.com
> >         Regression: Yes
> >=20
> >=20
> > Created an attachment (id=3D25450)
> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=3D25450)
> > tcpdump from virtual guest over ::1 showing dup synacks
> >=20
> > Setup:
> > 64-bit dual-core, latest F12.  (I've experienced this on .31 and .3=
2 kernels.)
> >=20
> > I have also experienced this on 2 other machines, all 64-bit.  One =
was a
> > single-core virtual guest.
> >=20
> > 1. Install httpd.
> > 2. Start it.  Don't bother configuring anything unless you need to.
> > 3. tcpdump .....
> > 4. connect from localhost or (possibly) a nearby host.  I'm not sur=
e if this is
> > timing related yet.
> > 5. note duplicate SYN-ACKs sent out at the exponential backoff.  So=
me setups
> > exhibit this more/worse than others, and will actually time out the=
 connection.
> >  (Others will only send one or two duplicate SYN-ACKs, and then ent=
er the
> > ESTABLISHED state.)  However, if any data is sent the kernel enters
> > ESTABLISHED.
> >=20
> > Note that this isn't ipv4 specific.  I have seen it under ipv4 and =
ipv6 (via
> > loopback).
> >=20
>=20
> --

I would say this is expected if httpd server set DEFER_ACCEPT socket
option.



