From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] ipv6: Implement limits on Hop-by-Hop and
 Destination options
Date: Mon, 30 Oct 2017 19:39:33 -0700
Message-ID: <CALx6S34O8+aKSmbp5FR6X8uKhdZHijkUQFja_rSdyUDKKm4T1Q@mail.gmail.com>
References: <20171030211600.6491-1-tom@quantonium.net> <20171031.111026.1763034451245817288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:49107 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751399AbdJaCjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:39:35 -0400
Received: by mail-qk0-f182.google.com with SMTP id d67so18726458qkg.5
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:39:34 -0700 (PDT)
In-Reply-To: <20171031.111026.1763034451245817288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 7:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Mon, 30 Oct 2017 14:16:00 -0700
>
>> I wrote a quick test program that floods a whole bunch of these
>> packets to a host and sure enough there is substantial time spent
>> in ip6_parse_tlv.
>  ...
>>   25.38%  [kernel]                    [k] __fib6_clean_all
>>   21.63%  [kernel]                    [k] ip6_parse_tlv
>
> Yet the routing code still dominates the cost.

I wouldn't read too much into that. This was unconnected UDP on VMs
and the only purpose here was to demonstrate that ip6_parse_tlv does
get a lot of work with a lot of TLVs. Martin's results listed in the
tested section are probably a more accurate gauge of the impact and
potential to mitigate DOS.

Tom
