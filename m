From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Sat, 12 Apr 2014 07:43:51 -0400
Message-ID: <534926F7.10505@mojatatu.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net> <CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:58701 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbaDLLn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 07:43:59 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so2966323igb.3
        for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 04:43:59 -0700 (PDT)
In-Reply-To: <CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong,

You MUST specify flowid in your filter construct;->
So I agree with Stephen on the verdict on your patch.
We need a patch to avoid this FAQ problem since it happens
often i.e reject a filter that doesnt have flow/classid
specified. How about you provide that patch instead?

cheers,
jamal

On 04/11/14 21:15, Cong Wang wrote:
> On Fri, Apr 11, 2014 at 5:58 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Fri, 11 Apr 2014 17:45:53 -0700
>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> It's already there:
>>>
>>>          } else if (sel && sel->flags&TC_U32_TERMINAL) {
>>>                  fprintf(f, "terminal flowid ??? ");
>>>          }
>>
>> But it printing it like an error, not an known good option.
>> The ??? implies that somebody did something wrong.
>
> I don't know why ??? is displayed together with terminal, but
> nothing seems wrong here, check the output after I add
> a mirred action:
>
> filter protocol ip pref 49152 u32
> filter protocol ip pref 49152 u32 fh 800: ht divisor 1
> filter protocol ip pref 49152 u32 fh 800::800 order 2048 key ht 800
> bkt 0 terminal flowid ???
>    match 01020304/ffffffff at 16
> action order 1: mirred (Egress Mirror to device virbr0) pipe
>    index 1 ref 1 bind 1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
