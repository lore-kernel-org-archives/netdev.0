From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] bonding: don't permit slaves to change their
 mtu
Date: Tue, 14 Jan 2014 14:51:16 +0800
Message-ID: <52D4DE64.90708@huawei.com>
References: <52D4A8A7.60100@huawei.com> <20140114061556.GA7798@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.66] ([119.145.14.66]:40625 "EHLO
	szxga03-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaANG4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:56:03 -0500
In-Reply-To: <20140114061556.GA7798@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 14:15, Veaceslav Falico wrote:
> On Tue, Jan 14, 2014 at 11:01:59AM +0800, Ding Tianhong wrote:
>> The commit 2315dc91a5059d7da9a8b9b9daf78d695c11383e
>> (net: make dev_set_mtu() honor notification return code)
>> will deal with the return value for NETDEV_CHANGEMTU notification,
>> and the slaves should not change their mtu, so add return value
>> to prevent doing it.
> 
> In another email you said you've tested the mtu changes and some of the
> bonds have packet loss when mtu is changed, and some of them don't.
> 
> Maybe it'd be good to understand which modes can tolerate the mtu change
> (if it can be tolerated at all/if it should really matter) and allow it for
> specific bond modes only/for any bond modes?
> 
Ok, need more analysis.


>>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> 
> Don't add my name unless I specifically ask you to, please.
> 
> Thank you.
> 

Ok

>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 16 ++++------------
>> 1 file changed, 4 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index e06c445..af4e678 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2846,19 +2846,11 @@ static int bond_slave_netdev_event(unsigned long event,
>>          */
>>         break;
>>     case NETDEV_CHANGEMTU:
>> -        /*
>> -         * TODO: Should slaves be allowed to
>> -         * independently alter their MTU?  For
>> -         * an active-backup bond, slaves need
>> -         * not be the same type of device, so
>> -         * MTUs may vary.  For other modes,
>> -         * slaves arguably should have the
>> -         * same MTUs. To do this, we'd need to
>> -         * take over the slave's change_mtu
>> -         * function for the duration of their
>> -         * servitude.
>> +        /* The master and slaves should have the
>> +         * the same mtu, so do't permit slaves
>> +         * to change their mtu independently.
>>          */
>> -        break;
>> +        return NOTIFY_BAD;
>>     case NETDEV_CHANGENAME:
>>         /*
>>          * TODO: handle changing the primary's name
>> -- 
>> 1.8.0
>>
>>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
