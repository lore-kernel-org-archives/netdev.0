From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 18:54:30 +0200
Message-ID: <1307724870.4044.20.camel@edumazet-laptop>
References: <4DF0E638.2010506@uth.tmc.edu>
	 <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu>
	 <4DF24154.3060505@uth.tmc.edu> <1307722621.4044.17.camel@edumazet-laptop>
	 <4DF248C5.9050004@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56694 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1FJQye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 12:54:34 -0400
Received: by wwa36 with SMTP id 36so2984010wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 09:54:33 -0700 (PDT)
In-Reply-To: <4DF248C5.9050004@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 11:39 -0500, Charles Bearden a =C3=A9cr=
it :
> On 06/10/2011 11:17 AM, Eric Dumazet wrote:
> > Le vendredi 10 juin 2011 =C3=A0 11:07 -0500, Charles Bearden a =C3=A9=
crit :
> >
> >> You are correct: the checksums in the keepalives are broken, thoug=
h they are
> >> correct in the other segments from the Win2008 server. I have upda=
ted the pastes
> >> linked to above with 'tcpdump -v' output. I apologize for missing =
that problem
> >> the first time around.
> >
> > Hmm, maybe its OK : If checksums are offloaded to NIC, tcpdump 'lie=
s'
> > telling checksum is not OK, since tcpdump get a copy of the packet
> > before being handled by the NIC.
> >
> > You should take a tcpdump on the receiving machine (the machine tha=
t
> > apparently doesnt react to the keepalive probes)
>=20
> I should have made this clear before: these dumps were captured on th=
e machine=20
> that is ignoring the keepalives ("Ubuntu.host" in the dumps) from the=
 other host=20
> ("Win200[38].host" in the dumps). If I understand tcp checksum offloa=
ding=20
> correctly, it wouldn't play a role here.
>=20

OK, thanks.

I am curious, could you check the payload byte included in the keepaliv=
e
probes has the value of last sent byte on the session ?

(linux send keepalive probes with no data, so implementing this
'feature' would need to keep track of this value in tcp socket)



