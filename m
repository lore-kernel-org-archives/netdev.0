From: Szymon Miotk <spam@crocom.com.pl>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Wed, 10 Nov 2004 13:08:14 +0100
Message-ID: <419204AE.7030805@crocom.com.pl>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net> <418ECE85.9090203@trash.net> <20041108135431.GE31969@postel.suug.ch> <418F9AD0.1040701@trash.net> <20041108183300.GF31969@postel.suug.ch> <418FCD0A.4040202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418FCD0A.4040202@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Thomas Graf wrote:
> 
>> * Patrick McHardy <418F9AD0.1040701@trash.net> 2004-11-08 17:12
>>  
>>
>>> There is some optimization possible, I will do this for the final
>>> patch. But I don't understand the problem you refer to, can you
>>> please explain ?
>>>
>>
>> I don't have the time to verify this at the moment but:
>>
>> 1) qdisc_destroy unlinking all the lists
>> 2) RTM_NEWQDISC creating a new qdisc with the same major classid as 
>> the old one
>>   which will suceed since the old one cannot be found anymore.
>> 3) rcu callback __qdisc_destroy -> qdisc_destroy looking through 
>> qdisc_list
>>   again and then deleting the new entries because their major classid 
>> matches.
>>
>> I might be missing something though.
>>
> You're right, thanks. The optimization already fixed this, but I
> wasn't aware of the bug :) New patch attached.

I've tested the new kernel (2.6.10-rc1_bk17) with this patch.
It performed well on test system (reloading my traffic shaping 
configuration for 100 times).
Now it forks for some 22 hours on production system, under normal load 
(~20 Mbit, 500 clients at a time, 15000 entires in route table) and it 
performs well.

Thanks a lot for your help, it really saved me away from troubles.

Szymon Miotk
