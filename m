From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 16:18:39 -0700
Message-ID: <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com> <20160920230927.GG3291@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35827 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753878AbcITXSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:18:40 -0400
Received: by mail-qk0-f194.google.com with SMTP id w204so2044310qka.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:18:40 -0700 (PDT)
In-Reply-To: <20160920230927.GG3291@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 4:09 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/16 at 03:49pm, Tom Herbert wrote:
>> On Tue, Sep 20, 2016 at 3:44 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > On 09/20/16 at 03:00pm, Tom Herbert wrote:
>> >> +static inline int __xdp_hook_run(struct list_head *list_head,
>> >> +                              struct xdp_buff *xdp)
>> >> +{
>> >> +     struct xdp_hook_ops *elem;
>> >> +     int ret = XDP_PASS;
>> >> +
>> >> +     list_for_each_entry(elem, list_head, list) {
>> >> +             ret = elem->hook(elem->priv, xdp);
>> >> +             if (ret != XDP_PASS)
>> >> +                     break;
>> >> +     }
>> >
>> > Walking over a linear list? Really? :-) I thought this was supposed
>> > to be fast, no compromises made.
>>
>> Can you suggest an alternative?
>
> Single BPF program that encodes whatever logic is required. This is
> what BPF is for. If it absolutely has to run two programs in sequence
> then it can still do that even though I really don't see much of a
> point of doing that in a high performance environment.
>
> I'm not even sure yet I understand full purpose of this yet ;-)

This allows other use cases than BPF inserting code into the data
path. This gives XDP potential more utility and more users so that we
can motivate more driver implementations. For instance, I thinks it's
totally reasonable if the nftables guys want to insert some of their
rules to perform early DDOS drop to get the same performance that we
see in XDP.

Tom
