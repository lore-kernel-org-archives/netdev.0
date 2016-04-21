From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/4] libnl: enhance API to ease 64bit
 alignment for attribute
Date: Fri, 22 Apr 2016 00:00:09 +0200
Message-ID: <57194D69.4040206@6wind.com>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160421.142831.1815562418742721577.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37611 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbcDUWAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 18:00:14 -0400
Received: by mail-wm0-f46.google.com with SMTP id n3so153887099wmn.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 15:00:13 -0700 (PDT)
In-Reply-To: <20160421.142831.1815562418742721577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/04/2016 20:28, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu, 21 Apr 2016 18:58:23 +0200
>
>> Here is a proposal to add more helpers in the libnetlink to manage 6=
4-bit
>> alignment issues.
>> Note that this series was only tested on x86 by tweeking
>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS and adding some traces.
>>
>> The first patch adds helpers for 64bit alignment and other patches
>> use them.
>>
>> We could also add helpers for nla_put_u64() and its variants if need=
ed.
>>
>> v1 -> v2:
>>   - remove patch #1
>>   - split patch #2 (now #1 and #2)
>>   - add nla_need_padding_for_64bit()
>
> I like it, nice work Nicolas.
Thank you.

>
> Applied to net-next.
>
> I did a quick scan and the following jumped out at me as cases we nee=
d
> to fix up as well:
Did you grep something or just catch this by code review?

>
> 1) xfrm_user
> 2) tcp_info
> 3) taskstats
> 4) pkt_{cls,sched}
> 5) openvswitch
> etc.
>
> Most of these are statistic cases just like all of the existing ones
> we have fixed so far.
Yes, I will follow on this topic. There are also a bunch of
nla_put_[u|be|le]64():
$ git grep -w "nla_put_.\{1,2\}64" net/ | wc -l
118
$ git grep -w "nla_put_.\{1,2\}64" | wc -l
172
