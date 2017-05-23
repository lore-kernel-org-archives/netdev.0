From: Nithin Sujir <nsujir@tintri.com>
Subject: Re: bond link state mismatch, rtnl_trylock() vs rtnl_lock()
Date: Tue, 23 May 2017 14:35:41 -0700
Message-ID: <31e5860d-7e66-0a2d-99d6-7cde623f9c3c@tintri.com>
References: <24c0747b-df09-66da-f3ac-a393a5902a72@tintri.com>
 <CAF2d9jiUh2iVG4=igP0+e6dzZkff_h8u02taQts6hC2B2qsM2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0023b501.pphosted.com ([208.84.65.102]:60458 "EHLO
        mx0a-0023b501.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1032794AbdEWVft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 17:35:49 -0400
In-Reply-To: <CAF2d9jiUh2iVG4=igP0+e6dzZkff_h8u02taQts6hC2B2qsM2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/23/2017 2:30 PM, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Tue, May 23, 2017 at 12:32 PM, Nithin Sujir <nsujir@tintri.com> wrote:
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index 5dca77e..1f60503 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2614,8 +2614,7 @@ static void bond_loadbalance_arp_mon(struct
>> work_struct *work)
>>          rcu_read_unlock();
>>
>>          if (do_failover || slave_state_changed) {
>> -               if (!rtnl_trylock())
>> -                       goto re_arm;
>> +               rtnl_lock();
> Nitin, you can't do this. The tryRTNL code is to prevent deadlock
> during work-cancellation during bond_close().
Thanks, Mahesh. Yes, Jay pointed me to your patch and I will take a look 
at how to use a similar approach.

Nithin.

>>                  if (slave_state_changed) {
>>                          bond_slave_state_change(bond);
>>
>>
