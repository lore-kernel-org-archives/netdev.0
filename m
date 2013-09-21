From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v4] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Sat, 21 Sep 2013 03:28:29 +0200
Message-ID: <523CF63D.7030505@xdin.com>
References: <523A4F5E.9070503@xdin.com> <20130920.151017.2125552741552759738.davem@davemloft.net> <523CEBCD.10808@xdin.com> <523CF077.8010607@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arvid Brodin <arvid.brodin@xdin.com>, <netdev@vger.kernel.org>,
	<shemminger@vyatta.com>, <joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>, <elias.molina@ehu.es>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:49484 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab3IUB2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 21:28:34 -0400
In-Reply-To: <523CF077.8010607@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-09-21 03:03, Arvid Brodin wrote:
> On 2013-09-21 02:43, Arvid Brodin wrote:
>> It's weird though, the "len" bug doesn't show up in my practical tes=
ts -=20
>> scp of 16 MiB file (sha1sum compared afterwards) and ping with defau=
lt=20
>> and 65 KB packets work just fine before and after this change - even
>> between one fixed system and one with the bug remaining. Could it be
>> that none of the network device drivers we use (e1000e and macb) mak=
e=20
>> use of nonlinear skbs?
>=20
> Forget about this, e1000e is running on an architecture with=20
> HAVE_EFFICIENT_UNALIGNED_ACCESS, and on macb it does affect things -=20
> with the "fix" nothing works. :-|=20

=2E.. and that is because I have already shortened the packet through t=
he
call to strip_hsr_tag() a few lines above, which calls=20
skb_pull(..., HSR_TAGLEN) in turn. So ->len is already correct.

Moving both ->data and ->tail, and all data between them, HSR_TAGLEN by=
tes
lower, should not be a problem if

a) the space ahead of ->data is vacant (not part of the packet),
b) there is enough headroom,
c) it does not break 32-bit alignment, and
d) there are no references to headers etc in the data being moved.

Right?=20


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
