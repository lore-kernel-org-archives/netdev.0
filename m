From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Mon, 6 Mar 2017 13:36:57 -0800
Message-ID: <CAAsGZS5U_gX2-MTdnixtiNv8Wa8f+F7Wx7g=i3iffQEgruQ2bg@mail.gmail.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
 <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <586E9A0F.1020002@iogearbox.net> <CAAsGZS59KsGHJzG-U962kK4AP+M40zAV-ERgDqYvDLz5JB6Exg@mail.gmail.com>
 <CAF=yD-Jr5J9yoaNmBBSneL4HBuWcw3uRV4Smw=AnPAB+Sq9YSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:34327 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbdCFWdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 17:33:23 -0500
Received: by mail-ua0-f171.google.com with SMTP id f54so186339387uaa.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 14:31:33 -0800 (PST)
In-Reply-To: <CAF=yD-Jr5J9yoaNmBBSneL4HBuWcw3uRV4Smw=AnPAB+Sq9YSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 6, 2017 at 9:45 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Mon, Mar 6, 2017 at 12:13 PM, chetan loke <loke.chetan@gmail.com> wrote:
>>>>
>>>> Gosh. Can we also replace this BUG() into something less aggressive ?
>>>
>>>
>>> There are currently 5 of these WARN() + BUG() constructs and 1 BUG()-only
>>> for the 'default' TPACKET version spread all over af_packet, so probably
>>> makes sense to rather make all of them less aggressive.
>>>
>>>
>>
>> Very few consumers actually go looking in the kernel logs to see the
>> error-warnings and report them back here.
>>
>> This severity will get them to report the incident which in this case
>> got fixed??
>
> But BUG_ONs in the datapath can cause outages in real production
> environments. This should not happen for recoverable failures. For
> users who cannot be bothered to check their logs, there is sysctl
> kernel.panic_on_warn.


Completely understand(and you should have failover to handle these
outages). But then are you ok giving incorrect info to the
application?

For this specific bug: it is so basic that you should hit this bug 1st
time everytime when you are adding support or porting a new header.
Correct?

And so from that point of view, this BUG_ON has served its purpose.
