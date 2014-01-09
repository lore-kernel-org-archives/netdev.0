From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Thu, 9 Jan 2014 13:30:19 +0100
Message-ID: <20140109123019.GM5786@redhat.com>
References: <52CE8604.3010804@huawei.com>
 <20140109114636.GF5786@redhat.com>
 <52CE94DE.5030305@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbaAIMeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:34:22 -0500
Content-Disposition: inline
In-Reply-To: <52CE94DE.5030305@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 08:23:58PM +0800, Ding Tianhong wrote:
>On 2014/1/9 19:46, Veaceslav Falico wrote:
>> On Thu, Jan 09, 2014 at 07:20:36PM +0800, Ding Tianhong wrote:
>>> If the primary_slave's name changed, but the bond->prams.primay was
>>> still using the old name, it is conflict with the meaning of the
>>> primary, so update the primary when the slave change its name.
>>
>> Nope, the bonding parameter, which is set by the user, shouldn't change
>> because of an interface name change.
>>
>Yes, I know what you mean, but it is not bug fix, just make it more better,
>do not you feel it strange that the primary was different with primary_slave's name?

Yep, that's an issue - that's why there is the TODO. We shouldn't, though,
change the primary param, but rather check if the slave (that changed name)
is (already not) eligible for primary_slave.

>
>Regards
>Ding
>
>
>>>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> ---
>>> drivers/net/bonding/bond_main.c | 14 ++++++++++++--
>>> 1 file changed, 12 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index e06c445..de646e2 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -2860,9 +2860,19 @@ static int bond_slave_netdev_event(unsigned long event,
>>>          */
>>>         break;
>>>     case NETDEV_CHANGENAME:
>>> -        /*
>>> -         * TODO: handle changing the primary's name
>>> +        /* if the primary's name changed,
>>> +         * save the new name for primary.
>>>          */
>>> +        if (USES_PRIMARY(bond->params.mode) &&
>>> +            bond->params.primary[0]) {
>>> +            if (bond->primary_slave &&
>>> +                strcmp(bond->params.primary,
>>> +                   bond->primary_slave->dev->name)) {
>>> +                strncpy(bond->params.primary,
>>> +                    bond->primary_slave->dev->name,
>>> +                    IFNAMSIZ);
>>> +            }
>>> +        }
>>>         break;
>>>     case NETDEV_FEAT_CHANGE:
>>>         bond_compute_features(bond);
>>> --
>>> 1.8.0
>>>
>>>
>>
>>
>
>
