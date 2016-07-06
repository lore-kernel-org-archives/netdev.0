From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Wed, 6 Jul 2016 06:02:51 -0400
Message-ID: <577CD74B.5070805@mojatatu.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
 <20160704.151435.624086916441807197.davem@davemloft.net>
 <577B942A.2020602@mojatatu.com>
 <CAM_iQpVrfmVW2m9u0tGfy=WA9joV7Ssu9V+DR+0kbm=yNQ8Yzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36016 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcGFKC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 06:02:59 -0400
Received: by mail-io0-f195.google.com with SMTP id s63so23274803ioi.3
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 03:02:59 -0700 (PDT)
In-Reply-To: <CAM_iQpVrfmVW2m9u0tGfy=WA9joV7Ssu9V+DR+0kbm=yNQ8Yzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-05 02:19 PM, Cong Wang wrote:
> On Tue, Jul 5, 2016 at 4:04 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> Second arguement  usability, from:

>> to:
>> $TC filter add dev $ETH parent 1: protocol ip prio 10 \
>>      u32 match ip protocol 1 0xff flowid 1:2 \
>>      action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15
>>
>> given that I have to do this many many times in scripts and the
>> second policy is better eye candy.
>
> How about adding a "wrapper" in iproute2 pedit action to make
> it accept "dst mac xx:xx:xx:xx:xx:xx"? Like what we did for u32
> filters.
>

Thats what we do today. Its fugly and debugging is nasty
(having to stare at 10s or hundreds of outputs looking at
offset and bytes when something goes wrong).
It is ok to use pedit as a starting point because you can
quickly craft things without any kernel changes.
But when you start heavily using something handcrafted
its usability starts affecting you.
I will work on and send the skbmod patch next time i
get cycles.

cheers,
jamal
