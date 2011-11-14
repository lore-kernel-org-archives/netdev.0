From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: Re: [PATCH RESUBMIT2 net-next 1/2] IPv6 routing, NLM_F_* flag
 support: warn if NEWROUTE lacks of both CREATE and REPLACE flags
Date: Mon, 14 Nov 2011 10:31:20 +0200
Message-ID: <1321259480.23935.75.camel@hakki>
References: <1321254611.23935.15.camel@hakki>
	 <20111114.020617.136865443034405914.davem@davemloft.net>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:13085 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab1KNITd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 03:19:33 -0500
In-Reply-To: <20111114.020617.136865443034405914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 02:06 -0500, ext David Miller wrote:
> These changes still has problems.
>=20
> These warning messages are poorly formatted.  Some of them don't even=
 indicate
> that ipv6 is involved by printing out an appropriate subsystem prefix=
=2E
>=20
> And frankly, they are ugly, and not the kind of thing I want the netw=
orking
> code spitting out.
>=20
> Consolidate these messages into something that has good form and will=
 indicate,
> consistently, where the trouble is occuring.

Messages can be changed, that's no problem. I would like to hear sugges=
tions=20
because I personally see not much problems in current messages.=20
(Of course printing out the subsystem is obvious improvement now that y=
ou=20
mentioned it).=20
It is hard for me to think something better that would still be short
warning telling what's wrong.

> And I still submit that perhaps these ugly messages are an indicate o=
f how
> bad an idea these changes are in the first place.  We've lived with t=
he
> current behavior for 15 years or more, nobody cared.  What changed?

Need for IPv6 is what changed for me. I've lived past 15 years purely w=
ith IPv4.=20
I expect this change to be true for more users in the future - although=
 I
cant say I expect IPv6 to be be suddenly utilized everywhere.

> What can't you do with the current setup?  And why can't you do it wi=
thout
> requiring operations that work currently to change semantics?

Short answers: I cant just easily replace a route. And I cannot maintai=
n
old way if I want to respect netlink specifications.

Longer story:

Why I started writing this patch is that I had unpleasant surprizes whe=
n I=20
tried using netlink for IPv6 route manipulations first time. I noticed =
that=20
IPv6 does not use netlink API as user (I) could expect.=20

1. Replacing a route surprised me. I did not expect that request with n=
o=20
CREATE flag would create a new route. That's what happens. Even with
NLM_F_REPLACE

2. Also it was not possible to replace a route in single netlink messag=
e.=20

What got me even more puzzled is, that no warning, no error, no nothing=
 was
returned to me when I set NLM_F_REPLACE flag. I would have expected -EN=
OTSUP
if there's no support. Or -EINVAL. I had no idea that flag was not supp=
orted.
I addmitt it was propably stupid to expect IPv6 to work in same way as =
IPv4
does. However I used netlink for IPv4 too, so I assumed whatI tried wit=
h IPv6
 was correct. Finally I had to look at the kernel sources to find out w=
hat=20
happens. I believe that prints (even ugly ones) are better than making=20
avera=C7=B5e Joe like me to search for the answers from kernel sources.

Anyways, what really improves usability is support for REPLACE flag.
Instead of issuing REPLACE request user now needs to:

1. issue GET request to see if there is routes to given destination
2. explisitly delete the matching route
3. create new route and
4. keep on eye the changes done by other processes.

That is whole a lot more work for user, and that requires route manipul=
ation
tools to do different handling for IPv4 and IPv6 routes.

I believe respecting all flags according to netlink specifications woul=
d be
what new users expect. Thats why my patch also handles NLM_F_CREATE and=
=20
NLM_F_EXCL flags.

However, I think that in usability point of view the support for=20
NLM_F_REPLACE  would be sufficient. Rest is more to fullfill the=20
specification.

[siedenote: And if we further ponder the NLM_F_* flags that would
improve usability, then NLM_F_MATCH with GET requests is what I would
like. (Returning only routes matching values given in request).=20
However that's not really supported by IPv4 either, so not having it in=
 IPv6=20
is not really a priority.]

Anyways, this is the discussion I hoped for before I wrote the patches.=
=20
And in my first post to this list I asked if the support for these flag=
s=20
was left out in purpose. So please let me know, if you think these chan=
ges=20
are unnecessary and wont be included in any case. Then I can just give =
up=20
polluting your list with mails and patches, and stop wasting your and m=
y=20
time. However if you think these changes are worthy, then no problem,=20
I can do required fixups to these patches. I just would like to know
what changes are acceptable / wanted.


--=20
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
=2E..but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
