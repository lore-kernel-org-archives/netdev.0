From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: Fri, 11 Mar 2005 09:01:31 +0200 (EET)
Message-ID: <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net>
 <1110481248.1074.306.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Jamal Hadi Salim <hadi@znyx.com>
In-Reply-To: <1110481248.1074.306.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005, Jamal Hadi Salim wrote:

>
> Agreed on both counts.
>
> Note, however, the tc_u32_mark should die Real Soon Now given the
> meta match patches that are in from Thomas.

It can die, but there are users that use it.
So, I think that as long as u32 will stay in kernel, we can let 
mark_in_u32 live.
It's a small modification and I think it may stay.
Thank you.

> cheers,
> jamal
>
>
> On Thu, 2005-03-10 at 13:42, Stephen Hemminger wrote:
>> The tc_u32_mark structure is used as part of the netlink message
>> from the user API to the kernel, so it needs to be moved to include/linux/pkt_cls.h
>> and have types changed from u32 to __u32.
>>
>> Also, the definition of u32 performance counters doesn't need to depend
>> on the config option.  The definition can exist even if the code isn't
>> enabled.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>>
>> diff -Nru a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
>> --- a/include/linux/pkt_cls.h	2005-03-10 10:36:39 -08:00
>> +++ b/include/linux/pkt_cls.h	2005-03-10 10:36:39 -08:00
>> @@ -221,14 +221,20 @@
>>  	struct tc_u32_key	keys[0];
>>  };
>>
>> -#ifdef CONFIG_CLS_U32_PERF
>> +struct tc_u32_mark
>> +{
>> +	__u32		val;
>> +	__u32		mask;
>> +	__u32		success;
>> +};
>> +
>>  struct tc_u32_pcnt
>>  {
>>  	__u64 rcnt;
>>  	__u64 rhit;
>>  	__u64 kcnts[0];
>>  };
>> -#endif
>> +
>>  /* Flags */
>>
>>  #define TC_U32_TERMINAL		1
>> diff -Nru a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>> --- a/net/sched/cls_u32.c	2005-03-10 10:36:39 -08:00
>> +++ b/net/sched/cls_u32.c	2005-03-10 10:36:39 -08:00
>> @@ -58,14 +58,6 @@
>>  #include <net/act_api.h>
>>  #include <net/pkt_cls.h>
>>
>> -
>> -struct tc_u32_mark
>> -{
>> -	u32		val;
>> -	u32		mask;
>> -	u32		success;
>> -};
>> -
>>  struct tc_u_knode
>>  {
>>  	struct tc_u_knode	*next;
>
>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
