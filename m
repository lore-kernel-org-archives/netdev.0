From: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Wed, 6 Feb 2013 14:53:48 +0100
Message-ID: <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com>
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
To: jamal <j.hadi123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51125744.3030905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

Le 6 f=E9vr. 2013 =E0 14:14, jamal a =E9crit :

>=20
> On 13-02-05 03:12 AM, Steffen Klassert wrote:
>>> For example, executing the below commands in that order succeed:
>>>  ip -6 xfrm policy flush
>>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark=
 1 mask 0xffffffff
>>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
>> The policy with mark 1 is the first we find. The policy passes the
>> mark check and if the flow matches the selectors, we use this policy=
=2E
>>=20
>>> But it fails in the reverse order:
>>>  ip -6 xfrm policy flush
>>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
>>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark=
 1 mask 0xffffffff
>>>  RTNETLINK answers: File exists
>> With this scenario, we would find the policy with mark and mask 0 fi=
rst.
>> This policy passes the mark check too. So we would use this policy i=
f the
>> flow matches the selectors, but the flow asked for a policy with mar=
k 1.
>=20
> I think the intent Romain is expressing is reasonable and should reso=
lved at
> insertion time(xfrm_policy_insert()).
> i.e even though the policy (such as mark=3D1) is inserted afterwards,=
 at
> insertion time if it proves it is more specific and not duplicate, it=
 should be
> inserted ahead of the mark=3D0.
> The runtime check will work then.

Actually, we didn't think about this problem since we work with priorit=
ies, putting the default policy (without a mark) at a minor priority th=
an the marked one.
Your remark makes clearer the ideas behind the design of XFRM, but this=
 leads to an interesting concern. If on policy insertion, the policy we=
re inserted depending on the accuracy of the mark (the more the mask is=
 specific, the more the mark must be put at the beginning of the list),=
 how would we decide which is the more specific between these ones ?

ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x00=
000001 mask 0x00000005

ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x00=
000001 mask 0x00000003

Best regards
Emmanuel Thierry
