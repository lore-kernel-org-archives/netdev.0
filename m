From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH net] tcp: update skb->skb_mstamp more carefully
Date: Thu, 14 Sep 2017 12:41:46 -0400
Message-ID: <CADAM+B1aZ3jZa4UJtzm2hvawGQ_GR0JGSUHwfR=SY=fARfM2mA@mail.gmail.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
 <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <e7e09201-40c2-933a-1e8e-a31eddcc75ab@huawei.com> <1505228700.15310.138.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505230686.15310.141.camel@edumazet-glaptop3.roam.corp.google.com>
 <b72fefba-e701-2ec8-0e7b-3bba6ed25205@huawei.com> <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
 <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADVnQy=OeD1C4xg6pdYY98djsGCdnKLv6PD5vC7j6-GSkfr8Yw@mail.gmail.com> <CAK6E8=dzYTaXnrXGeANX+wOtE+jfzX7M1ZokToe=ukm+tRK+Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        liujian <liujian56@huawei.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        wangkefeng 00227729 <wangkefeng.wang@huawei.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:33490 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdINQm1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 12:42:27 -0400
Received: by mail-vk0-f67.google.com with SMTP id j189so920721vka.0
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 09:42:27 -0700 (PDT)
In-Reply-To: <CAK6E8=dzYTaXnrXGeANX+wOtE+jfzX7M1ZokToe=ukm+tRK+Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 14, 2017 at 12:32 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Thu, Sep 14, 2017 at 6:57 AM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Wed, Sep 13, 2017 at 11:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>
>>> From: Eric Dumazet <edumazet@googl.com>
>>>
>>> liujian reported a problem in TCP_USER_TIMEOUT processing with a patch
>>> in tcp_probe_timer() :
>>>       https://www.spinics.net/lists/netdev/msg454496.html
>>>
>>> After investigations, the root cause of the problem is that we update
>>> skb->skb_mstamp of skbs in write queue, even if the attempt to send a
>>> clone or copy of it failed. One reason being a routing problem.
>>>
>>> This patch prevents this, solving liujian issue.
>>>
>>> It also removes a potential RTT miscalculation, since
>>> __tcp_retransmit_skb() is not OR-ing TCP_SKB_CB(skb)->sacked with
>>> TCPCB_EVER_RETRANS if a failure happens, but skb->skb_mstamp has
>>> been changed.
>>>
>>> A future ACK would then lead to a very small RTT sample and min_rtt
>>> would then be lowered to this too small value.
>> ...
>>>
>>> Signed-off-by: Eric Dumazet <edumazet@googl.com>
>>> Reported-by: liujian <liujian56@huawei.com>
>>> ---
>>>  net/ipv4/tcp_output.c |   19 ++++++++++++-------
>>>  1 file changed, 12 insertions(+), 7 deletions(-)
>>
>> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
Very nice! Thank you, Eric!
