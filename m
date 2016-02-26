From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH v2 net] bonding: don't use stale speed and duplex
 information
Date: Fri, 26 Feb 2016 10:21:51 +0800
Message-ID: <56CFB6BF.3070705@gmail.com>
References: <25869.1454962202@famine> <56CEBCC6.3040008@gmail.com>
 <11163.1456407235@nyx>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	dingtianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36729 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbcBZCVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 21:21:22 -0500
Received: by mail-pf0-f194.google.com with SMTP id e127so3873356pfe.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:21:22 -0800 (PST)
In-Reply-To: <11163.1456407235@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2016 09:33 PM, Jay Vosburgh wrote:
> zhuyj <zyjzyj2000@gmail.com> wrote:
> [...]
>> I delved into the source code and Emil's tests. I think that the problem
>> that this patch expects to fix occurs very unusually.
>>
>> Do you agree with me?
>>
>> If so, maybe the following patch can reduce the performance loss.
>> Please comment on it. Thanks a lot.
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index b7f1a99..c4c511a 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2129,7 +2129,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                         continue;
>>
>>                 case BOND_LINK_UP:
>> -                       bond_update_speed_duplex(slave);
>> +                       if (slave->speed == SPEED_UNKNOWN)
>> +                               bond_update_speed_duplex(slave);
>> +
>>                         bond_set_slave_link_state(slave, BOND_LINK_UP,
>> BOND_SLAVE_NOTIFY_NOW);
>>                         slave->last_link_up = jiffies;
> 	I don't believe the speed is necessarily SPEED_UNKNOWN coming in
> here.  If the race occurs at a time later than the initial enslavement,
> speed may already be set (and the race manifests if the new speed
> changes, i.e., the link changes from 1 Gb/sec to 10 Gb/sec), so I don't
> think this is functionally correct.
Hi, Jay

Thanks for your reply.

IMHO, "If the race occurs at a time later than the initial enslavement,
speed may already be set (and the race manifests if the new speed
changes, i.e., the link changes from 1 Gb/sec to 10 Gb/sec)", from my test,
this will not happen because the previous source code make the speed 
correct.

This "bond_update_speed_duplex" repeats to get the correct speed.

That is, this patch is to fix the error in initial enslavement. The 
mentioned scenario
will not occur.

Even though the performance impact is minimal, if we can avoid this 
performance
impact, why not ?

Best Regards!
Zhu Yanjun

>
> 	Also, the call to bond_miimon_commit itself is already gated by
> bond_miimon_inspect finding a link state change.  The performance impact
> here should be minimal.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
