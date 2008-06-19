From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Thu, 19 Jun 2008 18:28:46 +0200
Message-ID: <485A893E.4080405@free.fr>
References: <200806171504.38702.bpidoux@free.fr> <20080617.223050.266166325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080617.223050.266166325.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Unfortunately I don't quite understand exactly why a structure in user=20
space cannot be changed.
But this means that I have to make some effort to learn a bit more abou=
t=20
the kernel structure and userspace.
However, thank you for your explanation about how to fix the discrepanc=
y=20
between both timer structures.
I will try to dig out more information on this subject.

Bernard Pidoux, f6bvp
=20

David Miller a =E9crit :
> From: Bernard Pidoux <bpidoux@free.fr>
> Date: Tue, 17 Jun 2008 15:04:38 +0200
>
>  =20
>> In linux/include/linux/ax25.h
>> ax25_info_struct timers types remain unsigned
>>
>> struct ax25_info_struct {
>> 	unsigned int	n2, n2count;
>> 	unsigned int	t1, t1timer;
>> 	unsigned int	t2, t2timer;
>> 	unsigned int	t3, t3timer;
>> 	unsigned int	idle, idletimer;
>>         .....
>> };
>>
>> while in linux/include/net/ax25.h timers are unsigned long according
>> to kernel 2.6 timers.
>>
>> typedef struct ax25_cb {
>>         .....
>>         struct timer_list       t1timer, t2timer, t3timer, idletimer=
;
>>         unsigned long           t1, t2, t3, idle, rtt;
>>         ....
>>
>> Although ax25_info_struct is not much used it is refered at least
>> into libax25 and xfbb BBS application program.
>>
>> It seems thus reasonable to make the change.
>>
>> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
>>    =20
>
> Unfortunately this datastructure is exported to userspace,
> and therefore we cannot change the structure layout without
> breaking userspace.
>
> We cannot, as a result, make this change.
>
> The only way to fix this is to make a new fixed structure, and add ne=
w
> ax25 calls that accept this new structure.
>
>
>  =20

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
