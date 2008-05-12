From: "Damon L. Chesser" <damon@damtek.com>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 15:18:54 -0400
Message-ID: <4828981E.1000104@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi> <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com> <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com> <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi> <482849C9.30905@damtek.com> <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi> <48288EFE.4020708@damtek.com> <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from damtek.com ([72.172.134.65]:44885 "EHLO damtek.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761AbYELTSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 15:18:55 -0400
In-Reply-To: <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Mon, 12 May 2008, Damon L. Chesser wrote:
>
>> Ilpo J=E4rvinen wrote:
>> > On Mon, 12 May 2008, Damon L. Chesser wrote:
>> >
>> > > I applied the patches in order, no errors on that.  I compiled a=
=20
>> stock
>> > > 2.4.24-1 kernel with the patches, I saw no errors there.
>> > >
>> > > booted into new kernel, printed with tcp_frto=3D0.  set tcp_frto=
 =3D2,
>> > > restarted
>> > > the network (is this required, or is this a dynamic setting?),=20
>> printed
>> > > from OO
>> > > document.  No joy.  tcpdump log attached (almost 15 min. worth o=
f=20
>> data)
>> > >
>> > > If you want, I can re-compile and double check for any=20
>> compilation errors,
>> > > however, if there were any, it was not sever enough to stop the
>> > > compilation.
>> >
>> > On the bright side, the FRTO problem that was occuring previously=20
>> is now
>> > fixed but there seems to be very few ways to communicate with that=
=20
>> device
>> > sanely because it assumes in-order arrival and keeps discarding, a=
s it
>> > seems, _all_ other segments... If you could try with this addition=
al
>> > work-around attached (keep the fixes there as well). Turn
>> > tcp_frto_inorder_workaround sysctl to 1 before testing with FRTO.
>> >
>> > ...Can you please send a dump about working case too, this seems=20
>> rather
>> > nasty device to work with (tcp_frto =3D 0 is enough to attain it, =
no=20
>> need to
>> > have another kernel booted for that) and I'm interested to see wha=
t=20
>> are the
>> > loss rates without FRTO...
>> >
>> >
>> New patch added in with the first two, tcp_frto_inorder_workaround =3D=
1=20
>> test
>> printed 5 pages:  This worked.  Attached is the output of tcpdump.  =
Need
>> anything else?
>
> Thanks a lot for the testing & all. The picture is clear enough=20
> already, so no additional help needed (I haven't yet looked the=20
> non-frto dump but
> I doubt anything earth-shattering turns out, it's mostly interesting=20
> for finding out how efficiently such network printer TCP can consume=20
> segments it's receiving once FRTO related "fuzzy" ordering effects ar=
e=20
> removed, for comparison purposes, mostly interesting and that's for h=
c=20
> tcp guy like me :-)).
>
>
> Then one question for DaveM:
>
> What I'm not fully sure of, is do we want this workaround to be a=20
> sysctl or unconditionally enabled which causes potentially up to two=20
> unnecessary retransmissions? With SACK one or both of them will get=20
> SACKed before they get retransmitted (both cases have common=20
> scenarios). (I made that workaround patch for 2.6.24.1, so YMMV if yo=
u=20
> just plainly try to apply it to net-2.6).
>
One more question from me, what release will we see these updates in,=20
2.6.26?

--=20
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser

