From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 12:40:26 -0400
Message-ID: <1243c0c5-4a96-c54a-cdd2-17ea440ff6ad@mojatatu.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <7a49a797-d9cb-37c1-e46b-bec6888539b9@mojatatu.com>
 <1492441116.10587.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36265 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752751AbdDQQk3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 12:40:29 -0400
Received: by mail-io0-f196.google.com with SMTP id x86so27798601ioe.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 09:40:28 -0700 (PDT)
In-Reply-To: <1492441116.10587.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-17 10:58 AM, Eric Dumazet wrote:
[..]
> Very often, pads are there because of ABI constraints.
>
> We 'name' them to make clear to developers that they are there,
> and avoid security issues, because of say few bytes from kernel stack
> are copied to user space.
>
> struct foo {
>   __u32 a;
>   __u16 b;
> };
>
>
> Note that the 16bit padding is there, even if you do not name it.
>

Agreed. But note netlink is defined as "a wire protocol" which
has explicit requirement to pad/align to 32 bit boundary. Therefore
we _always_ explicitly name the pads.

> Once this structure had been exported to some include file and in a
> kernel, there is little point trying to 'reuse' the padding, unless for
> very specific cases.
>
> If you name paddings, then developers might think about it.
>

We always name them for netlink. The challenge is a few months later
we are not allowed to use the fields we name. I see these netlink
struct pads in the same manner as say reserved packet header fields.

cheers,
jamal
