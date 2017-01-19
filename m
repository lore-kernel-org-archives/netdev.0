From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Thu, 19 Jan 2017 05:37:19 -0800
Message-ID: <1484833039.16328.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484674356-22363-1-git-send-email-roman@advem.lv>
         <20170117.125844.253301507252169868.davem@davemloft.net>
         <CACiydbLuVf_jsWor6-OJmwQhxfwd=dzBDnDQnJrp3owf8qCkQA@mail.gmail.com>
         <1484680816.13165.73.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACiydbJV5djpKdsgnKTDfxHpC0aPhF-bdH=zVzGeo9x127RFJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35169 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753095AbdASNhg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 08:37:36 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so3395304pfa.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 05:37:31 -0800 (PST)
In-Reply-To: <CACiydbJV5djpKdsgnKTDfxHpC0aPhF-bdH=zVzGeo9x127RFJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 12:55 +0200, Roman Yeryomin wrote:
> On 17 January 2017 at 21:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Note that at 100M,  64 rx descriptors have a 8 ms max latency.
> >
> > Switching to 256 also multiply by 4 the latency -> 32 ms latency.
> >
> > Presumably switching to NAPI and GRO would avoid the latency increase
> > and save a lot of cpu cycles for a MIPS board.
> >
> 
> Eric, thanks for suggesting GRO, it gives huge performance gain when
> receiving locally (55->95Mbps) and more than 25% gain for NAT
> (55->70Mbps).
> Also reading the datasheet more carefully I see that device rx
> descriptor status flags are interpreted incorrectly. So will provide
> an updated set.

Oh right NAPI for rx is already implemented, so using GRO is a trivial
patch.
