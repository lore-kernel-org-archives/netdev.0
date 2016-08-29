From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 13:00:59 +0200
Message-ID: <57C415EB.80806@iogearbox.net>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com> <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com> <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46792 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756545AbcH2LBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:01:03 -0400
In-Reply-To: <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2016 12:38 PM, Jamal Hadi Salim wrote:
> On 16-08-28 12:07 PM, Eric Dumazet wrote:
>
>> Adding an action with a spinlock held in fast path in 2016 is
>> a way to tell people : It is a toy, do not use it for real.
>>
>> Sorry guys. Friends do not let friends do that anymore.
>
> Generally agree.
> Cong says he is working on generic patches. Let me see if i can
> try something. Trickery with RCU is not one of my virtues -
> so i may get it wrong but hope you can comment.

You could probably just keep these meta data in a separate struct
managed by RCU that tcf_skbmod points to.

One more thing I commented on your last patch already is that you
would also need f.e. skb_ensure_writable() before mangling.
