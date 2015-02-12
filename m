From: Bryton Lee <brytonlee01@gmail.com>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss - take 3
Date: Thu, 12 Feb 2015 09:21:44 +0800
Message-ID: <CAC2pzGdS4UuniF5cFpvgjbfvtX7q9JGDe0WAvYGBQNXxhNy18w@mail.gmail.com>
References: <1423547533-6727-1-git-send-email-brytonlee01@gmail.com>
	<54D9FED1.9030903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:43082 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbbBLBVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 20:21:45 -0500
Received: by mail-vc0-f175.google.com with SMTP id hq12so2595431vcb.6
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 17:21:44 -0800 (PST)
In-Reply-To: <54D9FED1.9030903@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 8:51 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 2/10/2015 8:52 AM, Bryton Lee wrote:
>
>> prevent the read ahead of /proc/slabinfo in ss.
>
>
>> Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
>> ---
>>   misc/ss.c | 13 ++++++++++---
>>   1 file changed, 10 insertions(+), 3 deletions(-)
>
>
>> diff --git a/misc/ss.c b/misc/ss.c
>> index 7fc0a99..74721b5 100644
>> --- a/misc/ss.c
>> +++ b/misc/ss.c
>
> [...]
>>
>> @@ -655,6 +656,8 @@ static int get_slabstat(struct slabstat *s)
>>                         break;
>>         }
>>
>> +    slabstat_valid = 1;
>
>
>    This is indented incorrectly. Use one TAB please.
>
>> +
>>         fclose(fp);
>>         return 0;
>>   }
>> @@ -2230,6 +2233,9 @@ static int tcp_show(struct filter *f, int socktype)
>>          * it is able to give us some memory for snapshot.
>>          */
>>         if (1) {
>> +               if (!slabstat_valid)
>> +                       get_slabstat(&slabstat);
>> +
>>                 int guess = slabstat.socks+slabstat.tcp_syns;
>>                 if (f->states&(1<<SS_TIME_WAIT))
>>                         guess += slabstat.tcp_tws;
>> @@ -3196,6 +3202,9 @@ static int print_summary(void)
>>         if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
>>                 perror("ss: get_snmpstat");
>>
>> +       if (!slabstat_valid)
>> +               get_slabstat(&slabstat);
>> +
>
>
>    Can't you perform this check inside get_slabstat()?
>

OK, I can submit it in another mail, coming soon.

> [...]
>
> WBR, Sergei
>



-- 
Best Regards

Bryton.Lee
