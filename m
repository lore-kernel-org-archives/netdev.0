From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix wraparound issue in tcp_lp
Date: Mon, 1 May 2017 20:31:35 -0400
Message-ID: <CADVnQy=iurcb+Ce3MKaB_szq-JOPerrPFvTxdy556O90qg1gWg@mail.gmail.com>
References: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com> <20170501165643.698aa0b5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34198 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbdEBAcG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 20:32:06 -0400
Received: by mail-io0-f175.google.com with SMTP id a103so135846383ioj.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 17:32:06 -0700 (PDT)
In-Reply-To: <20170501165643.698aa0b5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 1, 2017 at 7:56 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 01 May 2017 15:29:48 -0700
> Agreed time wraparound would cause problems.
> But why not use existing time_after() macro here?
>

I suspect this is because time_after() asserts that it is being used
on unsigned long (64 bits), and tcp_time_stamp is 32 bits.

I suppose for tcp_time_stamp comparisons we could re-use the u32 TCP
sequence macros for before() and after()? Even the comment for
before()/after() is already generic enough to apply to tcp_time_stamp:
"The next routines deal with comparing 32 bit unsigned ints and worry
about wraparound (automatic with unsigned arithmetic)." That might be
nice.

neal
