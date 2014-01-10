From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Fri, 10 Jan 2014 12:20:45 +0800
Message-ID: <52CF751D.1020200@huawei.com>
References: <52CE8604.3010804@huawei.com> <20140109114636.GF5786@redhat.com> <52CE94DE.5030305@huawei.com> <20140109123019.GM5786@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25463 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaAJEVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:21:13 -0500
In-Reply-To: <20140109123019.GM5786@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/9 20:30, Veaceslav Falico wrote:
> On Thu, Jan 09, 2014 at 08:23:58PM +0800, Ding Tianhong wrote:
>> On 2014/1/9 19:46, Veaceslav Falico wrote:
>>> On Thu, Jan 09, 2014 at 07:20:36PM +0800, Ding Tianhong wrote:
>>>> If the primary_slave's name changed, but the bond->prams.primay wa=
s
>>>> still using the old name, it is conflict with the meaning of the
>>>> primary, so update the primary when the slave change its name.
>>>
>>> Nope, the bonding parameter, which is set by the user, shouldn't ch=
ange
>>> because of an interface name change.
>>>
>> Yes, I know what you mean, but it is not bug fix, just make it more =
better,
>> do not you feel it strange that the primary was different with prima=
ry_slave's name?
>=20
> Yep, that's an issue - that's why there is the TODO. We shouldn't, th=
ough,
> change the primary param, but rather check if the slave (that changed=
 name)
> is (already not) eligible for primary_slave.
>=20

Ok=EF=BC=8CSo=EF=BC=8Csummarize your and my opinion, I think there are =
two ways to fix this:

1. just like my patch said.
2. check if the primary is not the primary_slave, make the primary_slav=
e =3D NULL, this means
   the primary_slave is no valid.
3. ?? did you have any better ideas?

Regards
Ding=20

>>
>> Regards
>> Ding
>>
>>
>>>>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>> drivers/net/bonding/bond_main.c | 14 ++++++++++++--
>>>> 1 file changed, 12 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding=
/bond_main.c
>>>> index e06c445..de646e2 100644
>>>> --- a/drivers/net/bonding/bond_main.c
>>>> +++ b/drivers/net/bonding/bond_main.c
>>>> @@ -2860,9 +2860,19 @@ static int bond_slave_netdev_event(unsigned=
 long event,
>>>>          */
>>>>         break;
>>>>     case NETDEV_CHANGENAME:
>>>> -        /*
>>>> -         * TODO: handle changing the primary's name
>>>> +        /* if the primary's name changed,
>>>> +         * save the new name for primary.
>>>>          */
>>>> +        if (USES_PRIMARY(bond->params.mode) &&
>>>> +            bond->params.primary[0]) {
>>>> +            if (bond->primary_slave &&
>>>> +                strcmp(bond->params.primary,
>>>> +                   bond->primary_slave->dev->name)) {
>>>> +                strncpy(bond->params.primary,
>>>> +                    bond->primary_slave->dev->name,
>>>> +                    IFNAMSIZ);
>>>> +            }
>>>> +        }
>>>>         break;
>>>>     case NETDEV_FEAT_CHANGE:
>>>>         bond_compute_features(bond);
>>>> --=20
>>>> 1.8.0
>>>>
>>>>
>>>
>>>
>>
>>
>=20
> .
>=20
