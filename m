From: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Wed, 6 Feb 2013 15:39:34 +0100
Message-ID: <5D4F2414-B869-46AA-B684-01F9EA88AD03@telecom-bretagne.eu>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com> <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu> <511268F0.5070808@mojatatu.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zproxy210.enst-bretagne.fr ([192.108.117.8]:59249 "EHLO
	zproxy210.enst-bretagne.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075Ab3BFOjh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 09:39:37 -0500
In-Reply-To: <511268F0.5070808@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 6 f=E9vr. 2013 =E0 15:30, Jamal Hadi Salim a =E9crit :

> On 13-02-06 08:53 AM, Emmanuel Thierry wrote:
>> Actually, we didn't think about this problem since we work with prio=
rities, putting the default policy (without a mark) at a minor priority=
 than the marked one.
>=20
> I think priorities are the way to go in cases of ambiguity.
>=20
>> Your remark makes clearer the ideas behind the design of XFRM, but t=
his leads to an interesting concern. If on policy insertion, the policy=
 were inserted depending on the accuracy of the mark (the more the mask=
 is specific, the more the mark must be put at the beginning of the lis=
t), how would we decide which is the more specific between these ones ?
>>=20
>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0=
x00000001 mask 0x00000005
>>=20
>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0=
x00000001 mask 0x00000003
>=20
> They look different to me, no? i.e i dont see a conflict - one has ma=
rk=3D5 and the other
> has mark=3D3.

I think you misread the example !
Marks are both 1, masks are different.

This case is more complex than a policy with no mark (so mark=3D0 and m=
ask=3D0) versus a policy with an exact mark (so mark=3D1 and mask=3D0xf=
fffffff), and i wanted to know if the algorithm would take these kind o=
f cases into account.

Best regards
Emmanuel Thierry
