From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: IPv4: sysctl table check failed [was: mmotm 2010-10-07-14-08
	uploaded]
Date: Sat, 9 Oct 2010 00:30:15 +0800
Message-ID: <20101008163015.GB5724@hack>
References: <201010072140.o97Le69i025659@imap1.linux-foundation.org> <4CAE4479.6010606@gmail.com> <1286490135.6536.75.camel@edumazet-laptop> <20101007152806.119d1522.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42335 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab0JHQ2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:28:11 -0400
Content-Disposition: inline
In-Reply-To: <20101007152806.119d1522.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 03:28:06PM -0700, Andrew Morton wrote:
>On Fri, 08 Oct 2010 00:22:15 +0200
>Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Le vendredi 08 octobre 2010 __ 00:06 +0200, Jiri Slaby a __crit :
>> > On 10/07/2010 11:08 PM, akpm@linux-foundation.org wrote:
>> > > The mm-of-the-moment snapshot 2010-10-07-14-08 has been uploaded to
>> > 
>> > Hi, I got bunch of "sysctl table check failed" below. All seem to be
>> > related to ipv4:
>> 
>> I would say, sysctl check is buggy :(
>> 
>> min/max are optional
>> 
>> [PATCH] sysctl: min/max bounds are optional
>> 
>> sysctl check complains when proc_doulongvec_minmax or
>> proc_doulongvec_ms_jiffies_minmax are used by a vector of longs (with
>> more than one element), with no min or max value specified.
>> 
>> This is unexpected, given we had a bug on this min/max handling :)
>> 
>> Reported-by: Jiri Slaby <jirislaby@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  kernel/sysctl_check.c |    9 ---------
>>  1 file changed, 9 deletions(-)
>> 
>> diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
>> index 04cdcf7..10b90d8 100644
>> --- a/kernel/sysctl_check.c
>> +++ b/kernel/sysctl_check.c
>> @@ -143,15 +143,6 @@ int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
>>  				if (!table->maxlen)
>>  					set_fail(&fail, table, "No maxlen");
>>  			}
>> -			if ((table->proc_handler == proc_doulongvec_minmax) ||
>> -			    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
>> -				if (table->maxlen > sizeof (unsigned long)) {
>> -					if (!table->extra1)
>> -						set_fail(&fail, table, "No min");
>> -					if (!table->extra2)
>> -						set_fail(&fail, table, "No max");
>> -				}
>> -			}
>>  #ifdef CONFIG_PROC_SYSCTL
>>  			if (table->procname && !table->proc_handler)
>>  				set_fail(&fail, table, "No proc_handler");
>
>That will probably fix it ;)


Yeah, it looks good for me too,

Acked-by: WANG Cong <xiyou.wangcong@gmail.com>

>
>net-avoid-limits-overflow.patch is dependent on this patch.  Unless
>Eric B squeaks I'll plan on sending this patch in for 2.6.37.
>

Eirc B reminded me we should check the code in sysctl_check.c,
but I forgot. The patch from Eric D is exactly what we need here.

Thanks.

