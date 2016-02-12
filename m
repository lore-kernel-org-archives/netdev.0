From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 20:59:57 +0000
Message-ID: <87a8n5able.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
	<87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
	<1455210224.2801.21.camel@decadent.org.uk>
	<87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	<87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	<87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<56BDA3A8.6070807@pmhahn.de>
	<8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
	<1455306847.2801.45.camel@decadent.org.uk>
	<87egchadk4.fsf@doppelsaurus.mobileactivedefense.com>
	<1455310037.2801.61.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Philipp Hahn <pmhahn@pmhahn.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455310037.2801.61.camel@decadent.org.uk> (Ben Hutchings's
	message of "Fri, 12 Feb 2016 20:47:17 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <ben@decadent.org.uk> writes:
> On Fri, 2016-02-12 at 20:17 +0000, Rainer Weikusat wrote:

[...]

>>>> I don't think this should apply when
>>>> receiving and sending sockets are identical. But that's just my
>>>> opinion. The other option would be to avoid the unix_state_double_=
lock
>>>> for sk =3D=3D other.
>>>=20
>>> Given that unix_state_double_lock() already handles sk =3D=3D other=
, I'm
>>> not sure why you think it needs to be avoided.
>>=20
>> Because the whole complication of restarting the operation after loc=
king
>> both sk and other because other had to be unlocked before calling
>> unix_state_double_lock is useless for this case:

[...]

> Well of course it's useless, but it's also harmless. =C2=A0

As is adding a

for (i =3D 0; i < 1000000; ++i);

between any two statements. And this isn't even entirely true as the
pointless double-lock will then require "did we pointlessly
doube-lock" checks elsewhere. I think it should be possible to do this
in a simpler way by not pointlessly double-locking (this may be
wrong but it's worth a try).

> If we really wanted to optimise this we could also skip unlocking if
> other < sk.

I wouldn't want to hardcode assumptions about the unix_state_double_loc=
k
algorithm in functions using it.=20
