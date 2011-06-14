From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net:  Ensure tx watchdog failures always print.
Date: Tue, 14 Jun 2011 10:25:13 -0700
Message-ID: <4DF79979.2070309@candelatech.com>
References: <1308070213-13244-1-git-send-email-greearb@candelatech.com> <1308071667.4870.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53515 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab1FNRZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:25:27 -0400
In-Reply-To: <1308071667.4870.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2011 10:14 AM, Eric Dumazet wrote:
> Le mardi 14 juin 2011 =C3=A0 09:50 -0700, greearb@candelatech.com a =C3=
=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> These are too important to not have some log message
>> generated.  But, keep the logic that only prints
>> a single stack dump.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 90939ba... fce5558... M	net/sched/sch_generic.c
>>   net/sched/sch_generic.c |   16 ++++++++++++++--
>>   1 files changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 90939ba..fce5558 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -252,8 +252,20 @@ static void dev_watchdog(unsigned long arg)
>>
>>   			if (some_queue_timedout) {
>>   				char drivername[64];
>> -				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queu=
e %u timed out\n",
>> -				       dev->name, netdev_drivername(dev, drivername, 64), i);
>> +				static bool do_once =3D true;
>> +				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s):"
>> +				       " transmit queue %u timed out,"
>> +				       " trans_start: %lu, wd-timeout: %i"
>> +				       " jiffies: %lu tx-queues: %i\n",
>> +				       dev->name,
>> +				       netdev_drivername(dev, drivername, 64),
>> +				       i,
>> +				       trans_start, dev->watchdog_timeo,
>> +				       jiffies, dev->num_tx_queues);
>> +				if (do_once) {
>> +					do_once =3D false;
>> +					WARN_ON(1);
>
> You could use WARN_ON_ONCE(1) here

Er, right..don't know what I was thinking.

Will re-send.

Thanks,
Ben

>
>> +				}
>>   				dev->netdev_ops->ndo_tx_timeout(dev);
>>   			}
>>   			if (!mod_timer(&dev->watchdog_timer,
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

