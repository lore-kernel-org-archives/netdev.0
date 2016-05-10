From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Tue, 10 May 2016 09:25:14 -0700
Message-ID: <57320B6A.3090301@cumulusnetworks.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com> <57248720.8060001@mojatatu.com> <5724CC01.3030203@cumulusnetworks.com> <573016F1.8050700@cumulusnetworks.com> <573084AC.6030407@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35460 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbcEJQZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 12:25:18 -0400
Received: by mail-qk0-f175.google.com with SMTP id n62so8740656qkc.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 09:25:17 -0700 (PDT)
In-Reply-To: <573084AC.6030407@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/9/16, 5:38 AM, Jamal Hadi Salim wrote:
> On 16-05-09 12:49 AM, Roopa Prabhu wrote:
>> On 4/30/16, 8:15 AM, Roopa Prabhu wrote:
>>> On 4/30/16, 3:21 AM, Jamal Hadi Salim wrote:
>
>> AFAICS ifstat history file handling today assumes all 32 bit stats.
>
> Indeed it does.
>
>> And to preserve backward compatibility, new ifstat should work with old and
>> new history files with 32bit and 64 bit stats.
>
> True.
> It may be ok to just provide a conversion tool maybe for taking 32b
> history into 64b? I dont know if someone is going to "migrate" their
> history files so even that may not be worth it.
>
>> The file format cannot be changed because of the same backward compat issues.
>> So, I am leaning towards a new history file with a new option (maybe ifstat -64) to
>> save/query 64 bit stats using the new api when available.
>>
>> I see some previous brief discussions on moving ifstat to 64 bit.
>>
>> The other option is to only change 'ip -s link show' to use the new stats api.
>>
>> let me know if there are other thoughts.
>>
>
> Is it not possible to convert to 64b - and IFLA_STAT
> becomes available just store it still in 64b?
> i.e 32b will fit in 64b space.

The only problem is again if the last saved history file had 32 bit
and 32bit counters may roll over earlier.

One more thing i am looking at right now which might work is using
 the existing history file and use the info_source (aka header) in ifstat history file to indicate
32bit or 64bit stats. For 32 bit it is currently "#kernel".
For 64 bit i plan to use "#kernel64".

If we are starting a new history file, i will always use 64bit and when using an existing history file,
it will use 32bit.

And 64bit stats will be queried with RTM_GETSTATS if available or will use IFLA_STATS64 when
RTM_NEWLINK Is used.

will see if i can get this working for all cases,

thanks,
Roopa
