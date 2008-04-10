From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 17:05:11 -0400
Message-ID: <47FE8107.4050400@rtr.ca>
References: <47FCF9DD.6080007@rtr.ca> <20080410.023045.16227424.yoshfuji@linux-ipv6.org> <47FD138B.2060801@rtr.ca> <20080409.152933.132174258.davem@davemloft.net> <47FD590C.5020003@rtr.ca> <Pine.LNX.4.64.0804101147070.24841@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>, linux-net@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759088AbYDJVF0@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804101147070.24841@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=C3=A4rvinen wrote:
> On Wed, 9 Apr 2008, Mark Lord wrote:
>=20
>> David Miller wrote:
>>> From: Mark Lord <lkml@rtr.ca>
>>> Date: Wed, 09 Apr 2008 15:05:47 -0400
>>>
>>>> But it would be far more useful for whoever has been working on th=
e
>>>> stack to suggest some possible/likely commits to look at instead.
>>> Personally all I see is that one side closes the socket before all
>>> data packets received have been read into the application, resultin=
g
>>> in a (correct) reset going out.
>>>
>>> I can't think of any change we've made over the course of this
>>> release that would change behvaior in that area.
>>>
>>> So you will likely need to bisect.
>> ..
>>
>> Or I can ignore it, like the net developers, since I have a workarou=
nd.
>> And then we'll see what other apps are broken upon 2.6.25 final rele=
ase.
>>
>> Really, folks.  Bug reports are intended to *help* the developers,
>> not something to be thrown back in their faces.
>>
>> There do seem to have been a *lot* of changes around the tcp closing=
/close
>> code (as I see from diff'ing 2.6.24 against latest -git).
=2E.
> I might help if would add netdev on cc list in case you really want t=
o=20
> reac net developers, otherwise they might just end up "ignoring it"..=
=2E ;-)
=2E.

Oh.. I didn't know about that list.  How does that differ from linux-ne=
t ?
(Thanks)

>=20
>> reducing the mountain of commits to a big handful or two.
>=20
> Those touching fin/close are mostly whitespace/move things, so I doub=
t=20
> that you find these useful but in case you insist, here's the list:
>
> 056834d9f6f6eaf4cc7268569e53acab957aac27 [TCP]: cleanup tcp_{in,out}p=
ut.c style
> 058dc3342b71ffb3531c4f9df7c35f943f392b8d [TCP]: reduce tcp_output's i=
ndentation levels a bit
> 490d5046930276aae50dd16942649bfc626056f7 [TCP]: Uninline tcp_set_stat=
e
>=20
> In addition, there's this one (...though I have read it number of tim=
es=20
> through and still cannot catch something that would cause the wrongne=
ss=20
> you're seeing):
>=20
> e870a8efcddaaa3da7e180b6ae21239fb96aa2bb [TCP]: Perform setting of co=
mmon=20
> control fields in one place
>=20
> There's very little really on interesting side I can think of, mostly=
=20
> thinks are congestion control related changes... ...maybe either one =
of=20
> these could cause something unpleasant in some corner case:
>=20
> bd515c3e48ececd774eb3128e81b669dbbd32637 [TCP]: Fix TSO deferring
> 0e3a4803aa06cd7bc2cfc1d04289df4f6027640a [TCP]: Force TSO splits to M=
SS boundaries
>=20
> ...e.g., if the latter causes a return with zero limit under some=20
> conditions, tso_fragment might generate, well, interesting packets an=
d=20
> never finish if the condition persists but.
=2E.

That matches my own assessment there, too: lot's of whitespace changes,
and not much real code difference on most paths.  Bummer.  :)

-ml
