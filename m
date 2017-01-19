From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Thu, 19 Jan 2017 12:55:16 +0200
Message-ID: <CACiydbJV5djpKdsgnKTDfxHpC0aPhF-bdH=zVzGeo9x127RFJg@mail.gmail.com>
References: <1484674356-22363-1-git-send-email-roman@advem.lv>
 <20170117.125844.253301507252169868.davem@davemloft.net> <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
 <1484680816.13165.73.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:35060 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdASKzR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 05:55:17 -0500
Received: by mail-vk0-f52.google.com with SMTP id x75so26790236vke.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 02:55:17 -0800 (PST)
In-Reply-To: <1484680816.13165.73.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2017 at 21:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-01-17 at 20:27 +0200, Roman Yeryomin wrote:
>> On 17 January 2017 at 19:58, David Miller <davem@davemloft.net> wrote:
>> > From: Roman Yeryomin <leroi.lists@gmail.com>
>> > Date: Tue, 17 Jan 2017 19:32:36 +0200
>> >
>> >> Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
>> >> This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)
>> >
>> > Those numbers don't mean much without full context.
>> >
>> > What kind of system, what kind of traffic, and over what kind of link?
>>
>> MIPS rb532 board, TCP iperf3 test over 100M link, NATed speed ~55Mbps.
>> I can do more tests and provide more precise numbers, if needed.
>
> Note that at 100M,  64 rx descriptors have a 8 ms max latency.
>
> Switching to 256 also multiply by 4 the latency -> 32 ms latency.
>
> Presumably switching to NAPI and GRO would avoid the latency increase
> and save a lot of cpu cycles for a MIPS board.
>

Eric, thanks for suggesting GRO, it gives huge performance gain when
receiving locally (55->95Mbps) and more than 25% gain for NAT
(55->70Mbps).
Also reading the datasheet more carefully I see that device rx
descriptor status flags are interpreted incorrectly. So will provide
an updated set.

Thanks for feedback!

Regards,
Roman
