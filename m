From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] bonding: update the primary when slave name
 changed
Date: Thu, 9 Jan 2014 20:23:58 +0800
Message-ID: <52CE94DE.5030305@huawei.com>
References: <52CE8604.3010804@huawei.com> <20140109114636.GF5786@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:64043 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaAIM12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 07:27:28 -0500
In-Reply-To: <20140109114636.GF5786@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/9 19:46, Veaceslav Falico wrote:
> On Thu, Jan 09, 2014 at 07:20:36PM +0800, Ding Tianhong wrote:
>> If the primary_slave's name changed, but the bond->prams.primay was
>> still using the old name, it is conflict with the meaning of the
>> primary, so update the primary when the slave change its name.
> 
> Nope, the bonding parameter, which is set by the user, shouldn't change
> because of an interface name change.
> 
Yes, I know what you mean, but it is not bug fix, just make it more better,
do not you feel it strange that the primary was different with primary_slave's name?

Regards
Ding


>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 14 ++++++++++++--
>> 1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index e06c445..de646e2 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2860,9 +2860,19 @@ static int bond_slave_netdev_event(unsigned long event,
>>          */
>>         break;
>>     case NETDEV_CHANGENAME:
>> -        /*
>> -         * TODO: handle changing the primary's name
>> +        /* if the primary's name changed,
>> +         * save the new name for primary.
>>          */
>> +        if (USES_PRIMARY(bond->params.mode) &&
>> +            bond->params.primary[0]) {
>> +            if (bond->primary_slave &&
>> +                strcmp(bond->params.primary,
>> +                   bond->primary_slave->dev->name)) {
>> +                strncpy(bond->params.primary,
>> +                    bond->primary_slave->dev->name,
>> +                    IFNAMSIZ);
>> +            }
>> +        }
>>         break;
>>     case NETDEV_FEAT_CHANGE:
>>         bond_compute_features(bond);
>> -- 
>> 1.8.0
>>
>>
> 
> 
