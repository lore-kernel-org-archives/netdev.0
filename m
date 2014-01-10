From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Fri, 10 Jan 2014 19:05:34 +0800
Message-ID: <52CFD3FE.9000805@huawei.com>
References: <52CE8604.3010804@huawei.com> <20140109114636.GF5786@redhat.com> <52CE94DE.5030305@huawei.com> <20140109123019.GM5786@redhat.com> <52CF751D.1020200@huawei.com> <20140110074433.GA26273@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:6025 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaAJLFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 06:05:55 -0500
In-Reply-To: <20140110074433.GA26273@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/10 15:44, Veaceslav Falico wrote:
> On Fri, Jan 10, 2014 at 12:20:45PM +0800, Ding Tianhong wrote:
>> On 2014/1/9 20:30, Veaceslav Falico wrote:
>>> On Thu, Jan 09, 2014 at 08:23:58PM +0800, Ding Tianhong wrote:
>>>> On 2014/1/9 19:46, Veaceslav Falico wrote:
>>>>> On Thu, Jan 09, 2014 at 07:20:36PM +0800, Ding Tianhong wrote:
>>>>>> If the primary_slave's name changed, but the bond->prams.primay =
was
>>>>>> still using the old name, it is conflict with the meaning of the
>>>>>> primary, so update the primary when the slave change its name.
>>>>>
>>>>> Nope, the bonding parameter, which is set by the user, shouldn't =
change
>>>>> because of an interface name change.
>>>>>
>>>> Yes, I know what you mean, but it is not bug fix, just make it mor=
e better,
>>>> do not you feel it strange that the primary was different with pri=
mary_slave's name?
>>>
>>> Yep, that's an issue - that's why there is the TODO. We shouldn't, =
though,
>>> change the primary param, but rather check if the slave (that chang=
ed name)
>>> is (already not) eligible for primary_slave.
>>>
>>
>> Ok=EF=BC=8CSo=EF=BC=8Csummarize your and my opinion, I think there a=
re two ways to fix this:
>>
>> 1. just like my patch said.
>=20
> No, the primary string is user-set, and it should *not* be changed by
> kernel.
>=20
>> 2. check if the primary is not the primary_slave, make the primary_s=
lave =3D NULL, this means
>>   the primary_slave is no valid.
>=20
> Check the slave that changed name - if it's the primary slave, remove=
 it,
> and see if we need to select the new active slave.=20

Ok, agree.

> If it's not the primray
> slave, and we don't have one - select it as a new primary and, again,=
 see
> if we need to select a new active slave.

I don't think so , I think if it is not the primary slave and we don't =
have one,
no need to do anything, just a normal slave change its name.

Regards
Ding

>=20
>> 3. ?? did you have any better ideas?
>>
>> Regards
>> Ding
>>

>>>>
>>>
>>> .
>>>
>>
>>
>=20
> .
>=20
