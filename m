From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: MPTCP: TCP-option or "experimental option"
Date: Sun, 05 Feb 2012 11:21:34 +0100
Message-ID: <4F2E582E.40403@uclouvain.be>
References: <4F2E4665.3080501@uclouvain.be> <1328435341.14474.19.camel@edumazet-laptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48775 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2BEKVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 05:21:40 -0500
In-Reply-To: <1328435341.14474.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc-ing netdev and Ilpo)

On 02/05/2012 10:49 AM, Eric Dumazet wrote:
> Le dimanche 05 f=C3=A9vrier 2012 =C3=A0 10:05 +0100, Christoph Paasch=
 a =C3=A9crit :
>> Hello David & Eric,
>>
>> the MPTCP working-group at the IETF is about to finalize the protoco=
l
>> specification. As MPTCP is currently not yet in Standards-Track, one
>> point of discussion is wheter we should request IANA for an early
>> assignment of a permanent TCP-option number or rather use the
>> experimental option with a "magic number" as described by
>> draft-ietf-tcpm-experimental-options-00
>>
>> My question is, whether the use of the experimental option would be =
a
>> blocker for upstream inclusion of our MPTCP-implementation? Especial=
ly,
>> as we then would have a hybrid situation as soon as MPTCP receives a
>> permanent TCP-option number.
>>
>>
>=20
> Hi Christoph
>=20
> Your question reminds me the TCPOPT_COOKIE still using 253, even in R=
=46C
> 6013...

Oh... Is there any plan on how to handle this, as soon as TCP-cookies
receives a "real" option-number?
Because there will be a situation where one implementation (using the
new number) cannot talk to the other one (using 253).

> Using an experimental option tends to stay as is a long time...

Yes, probably...

> Adding a magic number consumes a lot of space in tcp option space, so=
 it
> will be hard to use SACK + timestamps + MPTCP_with_magic_number ?

Yes. MPTCP is already using quite a lot of option-space. The
magic-number would make it even worse and give even less space for
SACK-blocks.

> Apparently, IANA is reluctant to consume some values on the ~200
> remaining values of tcp options ?

tcpcrypt is using two unassigned numbers in their implementation (as we
do for MPTCP ;) ).
This has been critized in an e-mail thread on tsvwg
(http://www.ietf.org/mail-archive/web/tsvwg/current/msg10957.html)

Upon this, a first draft has been proposed
(http://www.ietf.org/mail-archive/web/tcpm/current/msg06653.html),
resulting later-on in draft-ietf-tcpm-experimental-options-00 .

> How long does it take to get an official value from IANA ?

I don't think the problem is the time it takes to get this value (it
should not take very long).
The problem is rather, if there are compelling arguments for an early
assignment of an official value.
I fear that if the working-group concludes on the experimental option,
we have to wait for MPTCP going into standards-track before receiving a=
n
official number. And going the standards-track may still take a lot of =
time.


Personally, I would prefer to see MPTCP receiving an official TCP-optio=
n.

But my opinion doesn't really matter for the question if you guys at
netdev are for or against including code using this experimental option=
=2E
Especially due to the problem of this hybrid situation to support
interoperability among the kernel-versions.


Cheers,
Christoph


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20
