From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Tue, 5 Jul 2016 11:19:53 -0700
Message-ID: <CAM_iQpVrfmVW2m9u0tGfy=WA9joV7Ssu9V+DR+0kbm=yNQ8Yzw@mail.gmail.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
 <20160704.151435.624086916441807197.davem@davemloft.net> <577B942A.2020602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34805 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbcGESUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 14:20:14 -0400
Received: by mail-io0-f195.google.com with SMTP id 100so21569774ioh.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 11:20:13 -0700 (PDT)
In-Reply-To: <577B942A.2020602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 4:04 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Second arguement  usability, from:
>
> sudo $TC filter add dev $ETH parent ffff: pref 11 protocol ip u32 \
> match ip protocol 1 0xff flowid 1:2 \
> action pedit munge offset -14 u8 set 0x02 \
>         munge offset -13 u8 set 0x15 \
>         munge offset -12 u8 set 0x15 \
>         munge offset -11 u8 set 0x15 \
>         munge offset -10 u16 set 0x1515 \
>         pipe \
> action mirred egress redirect dev $SPANPORT
>
> to:
> $TC filter add dev $ETH parent 1: protocol ip prio 10 \
>     u32 match ip protocol 1 0xff flowid 1:2 \
>     action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15
>
> given that I have to do this many many times in scripts and the
> second policy is better eye candy.

How about adding a "wrapper" in iproute2 pedit action to make
it accept "dst mac xx:xx:xx:xx:xx:xx"? Like what we did for u32
filters.
