From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Sat, 18 Mar 2017 10:44:02 -0700
Message-ID: <CALx6S343iWzOKrKwHquG8qmyLyKOgQr_KroHyypE_9MFt2+1BQ@mail.gmail.com>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
 <674d67f5d76f761f3e872dff274a8bda@codeaurora.org> <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
 <1489191742.28631.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36eXpOn70paFnkSyafMkF7Q=MQWJKKb2=d6+hNpK-8V8A@mail.gmail.com> <e643b82c330eabfa0cef21c480eb6c2c@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:36519 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdCRRoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 13:44:04 -0400
Received: by mail-qt0-f176.google.com with SMTP id r45so83179880qte.3
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 10:44:03 -0700 (PDT)
In-Reply-To: <e643b82c330eabfa0cef21c480eb6c2c@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 10:32 AM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
>> All these hypotheses are quite testable, and it should be obvious that
>> if a patch is supposed to improve performance there should be some
>> effort to quantify the impact.
>
>
> Hi Tom
>
> I ran a single stream unconnected UDPv4 test on an ARM64 system and I see
> a slight increase in performance (782 -> 788Mbps) with udp demux disabled.
> A rudimentary app which does a sendto/recvfrom along with some
> statistics collection was used for this.
>
Less than 1% performance improvement in a benchmark doesn't justify
the complexity of the patch. Eric's hypothesis was that an unconnected
UDP socket may show issues because of cache misses in look-ups due to
so many different sources. This should be fairly easy to benchmark by
randomly setting source address in your test (IP any and routing my
need to be set appropriately).

> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
>
> a Linux Foundation Collaborative Project
