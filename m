From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 01:22:54 +0200
Message-ID: <57E1C4CE.7000104@iogearbox.net>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com> <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain> <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com> <20160920230927.GG3291@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34481 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753680AbcITXW7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:22:59 -0400
In-Reply-To: <20160920230927.GG3291@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2016 01:09 AM, Thomas Graf wrote:
> On 09/20/16 at 03:49pm, Tom Herbert wrote:
>> On Tue, Sep 20, 2016 at 3:44 PM, Thomas Graf <tgraf@suug.ch> wrote:
>>> On 09/20/16 at 03:00pm, Tom Herbert wrote:
>>>> +static inline int __xdp_hook_run(struct list_head *list_head,
>>>> +                              struct xdp_buff *xdp)
>>>> +{
>>>> +     struct xdp_hook_ops *elem;
>>>> +     int ret = XDP_PASS;
>>>> +
>>>> +     list_for_each_entry(elem, list_head, list) {
>>>> +             ret = elem->hook(elem->priv, xdp);
>>>> +             if (ret != XDP_PASS)
>>>> +                     break;
>>>> +     }
>>>
>>> Walking over a linear list? Really? :-) I thought this was supposed
>>> to be fast, no compromises made.
>>
>> Can you suggest an alternative?
>
> Single BPF program that encodes whatever logic is required. This is
> what BPF is for. If it absolutely has to run two programs in sequence
> then it can still do that even though I really don't see much of a
> point of doing that in a high performance environment.

Agreed, if there's one thing I would change in cls_bpf, then it's getting
rid of the (uapi unfortunately) list of classifiers and just make it a
single one, because that's all that is needed, and chaining/pipelining
can be done via tail calls for example. This whole list + callback likely
also makes things slower. Why not let more drivers come first to support
the current xdp model we have, and then we can move common parts to the
driver-independent core code?

> I'm not even sure yet I understand full purpose of this yet ;-)
