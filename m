From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss >
 window)
Date: Fri, 13 Jan 2017 07:35:34 -0800
Message-ID: <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34527 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdAMPfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 10:35:37 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so8880964pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 07:35:37 -0800 (PST)
In-Reply-To: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 18:01 +0300, Alexey Kodanev wrote:
> Hi,
> 
> Got the issue when running LTP/netstress test on localhost with mss
> greater than the send window advertised by client (right after 3WHS).
> Here is the testscenario that can reproduce this:

Hi Alexey

So this is a combination of Fastopen + small window + large MSS ?

I would rather not force burning tons of coal or other fossil fuel,
by making each tcp_sendmsg() done by billions of linux devices more
expensive, only to accommodate for some LTP test doing something not
sensible ;)

Fact that you removed one condition in the BUG_ON() might hide another
issue later in the path.

I would suggest to clamp MSS to half the initial window, but I guess
this is impractical since window in SYN/SYNACK are not scaled.

Care to send a packetdrill test so that we have a clear picture of what
is going on ?

Thanks.
