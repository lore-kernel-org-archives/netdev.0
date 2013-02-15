From: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: Re: tuntap: Overload handling
Date: Fri, 15 Feb 2013 08:04:44 +0100
Message-ID: <CAGUzgd+fVUEc6wqHbTdygAfbhuck5Hy7odtoGTFVQToHy6_7eg@mail.gmail.com>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
	<CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
	<1360859547.6884.51.camel@edumazet-glaptop>
	<20130214164053.GB18721@redhat.com>
	<1360861290.6884.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:39391 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3BOHEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 02:04:45 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1383826dak.33
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 23:04:44 -0800 (PST)
In-Reply-To: <1360861290.6884.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, thanks. So if you think of tuntap as a virtual device (and that's
what it is) then the drop behavior is quite a valid way.

So I'll gonna try to use the "old" version with qdisc support and
extend it be the features I need.

On Thu, Feb 14, 2013 at 6:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-02-14 at 18:42 +0200, Michael S. Tsirkin wrote:
>
>> Hmm so ~1000 packets in the tun queue is not enough?
>> You always have the option to increase it some more ...
>>
>> > You should ask Michael S. Tsirkin, as he removed the flow control
>> > in commit 5d097109257c03a71845729f8db6b5770c4bbedc
>> > (tun: only queue packets on device)
>> >
>>
>> Eric in the past you said the following things
>> (http://lkml.indiana.edu/hypermail/linux/kernel/1204.1/00784.html)
>> > > In your case I would just not use qdisc at all, like other virtual
>> > > devices.
>> ...
>> > > Anyway, with a 500 packet limit in TUN queue itself, qdisc layer should
>> > > be always empty. Whats the point storing more than 500 packets for a
>> > > device ? Thats a latency killer.
>> you don't think this applies, anymore?
>>
>
> Users have the choice to setup a qdisc or not.
>
> Having no qdisc can help raw performance, at the expense of bufferbloat.
> Thats all I was saying.
>
> It seems tun.c has no longer the possibility to effectively use a qdisc,
> (allowing the queue to buildup at qdisc layer)
>
>
>
