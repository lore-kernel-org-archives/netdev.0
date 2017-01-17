From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Tue, 17 Jan 2017 11:20:16 -0800
Message-ID: <1484680816.13165.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484674356-22363-1-git-send-email-roman@advem.lv>
         <20170117.125844.253301507252169868.davem@davemloft.net>
         <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35240 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdAQTUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:20:18 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so16797789pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:20:17 -0800 (PST)
In-Reply-To: <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-17 at 20:27 +0200, Roman Yeryomin wrote:
> On 17 January 2017 at 19:58, David Miller <davem@davemloft.net> wrote:
> > From: Roman Yeryomin <leroi.lists@gmail.com>
> > Date: Tue, 17 Jan 2017 19:32:36 +0200
> >
> >> Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
> >> This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)
> >
> > Those numbers don't mean much without full context.
> >
> > What kind of system, what kind of traffic, and over what kind of link?
> 
> MIPS rb532 board, TCP iperf3 test over 100M link, NATed speed ~55Mbps.
> I can do more tests and provide more precise numbers, if needed.

Note that at 100M,  64 rx descriptors have a 8 ms max latency.

Switching to 256 also multiply by 4 the latency -> 32 ms latency.

Presumably switching to NAPI and GRO would avoid the latency increase
and save a lot of cpu cycles for a MIPS board.
