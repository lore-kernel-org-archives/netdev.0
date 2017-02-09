From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page recycling
Date: Thu, 9 Feb 2017 08:56:25 -0800
Message-ID: <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
References: <20170209135838.16487-1-edumazet@google.com> <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
 <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com> <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35900 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932145AbdBIR0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:26:32 -0500
Received: by mail-io0-f176.google.com with SMTP id j13so22384080iod.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:26:27 -0800 (PST)
In-Reply-To: <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 8:49 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>
>
> On 09/02/2017 6:44 PM, Eric Dumazet wrote:
>>
>> On Thu, Feb 9, 2017 at 8:41 AM, Tariq Toukan <ttoukan.linux@gmail.com>
>> wrote:
>>>
>>> Hi Eric,
>>>
>>> Thanks again for your series.
>>>
>>> On 09/02/2017 3:58 PM, Eric Dumazet wrote:
>>>
>>> As mentioned half a year ago, we better switch mlx4 driver to order-0
>>> allocations and page recycling.
>>>
>>> This reduces vulnerability surface thanks to better skb->truesize
>>> tracking and provides better performance in most cases.
>>>
>>> v2 provides an ethtool -S new counter (rx_alloc_pages) and
>>> code factorization, plus Tariq fix.
>>>
>>> I see that you made significant changes to the previous series,
>>> especially
>>> patch 14 (RX CQE processing).
>>> Please notice that our work week has just finished here in Israel.
>>> I will review the series, especially the new patches (10 to 14), on
>>> Sunday.

> Default, out of box.

Well. Please report :

ethtool  -l eth0
ethtool -g eth0

>>
>>
>>> - TCP 16 streams at 1KB length.
>>
>> TCP does not really care, it coalesces all these into TSO skbs, full
>> size...
>
> But the kernel stack has to split it back accordingly in the receive side,
> no?

At 10Gbit or 40Gbit link speed, 16 TCP streams are sending 64KB TSO packets,
regardless of size of write() system calls.

Unless of course application uses write() with 1-byte, this might be
too expensive of course.
