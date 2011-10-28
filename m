From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 10:44:01 +0200
Message-ID: <1319791441.23112.80.camel@edumazet-laptop>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
	 <1319760097.19125.55.camel@edumazet-laptop>
	 <CAEnQRZAj4H9neNsGB8hkrQO5trvP8QimhKhpnwchjTVrAo2LGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49625 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215Ab1J1IoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 04:44:15 -0400
Received: by wyg36 with SMTP id 36so3640203wyg.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 01:44:14 -0700 (PDT)
In-Reply-To: <CAEnQRZAj4H9neNsGB8hkrQO5trvP8QimhKhpnwchjTVrAo2LGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 octobre 2011 =C3=A0 11:01 +0300, Daniel Baluta a =C3=A9c=
rit :
> On Fri, Oct 28, 2011 at 3:01 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le vendredi 28 octobre 2011 =C3=A0 02:07 +0300, Daniel Baluta a =C3=
=A9crit :
> >> RFC2581 ($4.2) specifies when an ACK should be generated as follow=
s:
> >>
> >> " .. an ACK SHOULD be generated for at least every second
> >>   full-sized segment, and MUST be generated within 500 ms
> >>   of the arrival of the first unacknowledged packet.
> >> "
> >>
> >> We export the number of segments and the timeout limits
> >> specified above, so that a user can tune them according
> >> to its needs.
> >>
> >
> > Well, this requires user has a machine exclusive use :)
>=20
> So, this means that setting parameters system wide
> isn't an option?
>=20

It is a first step, but we can notice a global setting might please one
application but negatively impact other applications.

I guess some users will want a per socket option, but this can come
later. An other idea to save space on socket structures would be to
select two set of values depending on TOS/TCLASS.

I can imagine ssh (lowdelay) and scp (throughput) wanting different
behavior here.

> On Windows there is a global setting TcpAckFrequency [1],
> which is similar with our tcp_delack_{min,max}.
>=20
> On Solaris there is a global option tcp_deferred_acks_max [2],
> which is similar with our tcp_delack_segs.
>=20

and also has tcp_deferred_ack_interval

> Thanks for your comments, I will post an updated patch asap.
>=20
> Daniel.
>=20
> [1] http://support.microsoft.com/kb/328890
> [2] http://www.sean.de/Solaris/soltune.html

Dont forget to CC Andy Lutomirski <luto@amacapital.net>, he might be
interested being part of the process.

Thanks
