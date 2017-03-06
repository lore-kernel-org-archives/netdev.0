From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Mon, 6 Mar 2017 12:45:58 -0500
Message-ID: <CAF=yD-Jr5J9yoaNmBBSneL4HBuWcw3uRV4Smw=AnPAB+Sq9YSw@mail.gmail.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
 <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <586E9A0F.1020002@iogearbox.net> <CAAsGZS59KsGHJzG-U962kK4AP+M40zAV-ERgDqYvDLz5JB6Exg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:34980 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753986AbdCFSOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 13:14:19 -0500
Received: by mail-wr0-f172.google.com with SMTP id g10so122655051wrg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 10:14:18 -0800 (PST)
In-Reply-To: <CAAsGZS59KsGHJzG-U962kK4AP+M40zAV-ERgDqYvDLz5JB6Exg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 6, 2017 at 12:13 PM, chetan loke <loke.chetan@gmail.com> wrote:
>>>
>>> Gosh. Can we also replace this BUG() into something less aggressive ?
>>
>>
>> There are currently 5 of these WARN() + BUG() constructs and 1 BUG()-only
>> for the 'default' TPACKET version spread all over af_packet, so probably
>> makes sense to rather make all of them less aggressive.
>>
>>
>
> Very few consumers actually go looking in the kernel logs to see the
> error-warnings and report them back here.
>
> This severity will get them to report the incident which in this case
> got fixed??

But BUG_ONs in the datapath can cause outages in real production
environments. This should not happen for recoverable failures. For
users who cannot be bothered to check their logs, there is sysctl
kernel.panic_on_warn.
