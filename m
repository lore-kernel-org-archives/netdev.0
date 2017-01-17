From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] tcp: accept RST for rcv_nxt - 1 after receiving
 a FIN
Date: Tue, 17 Jan 2017 11:13:39 -0800
Message-ID: <CANn89iJ-tc=m122UcEh9Xmuf1DoeKMwDf4Z42hWFZwxfRYFY_g@mail.gmail.com>
References: <1484678239-19199-1-git-send-email-jbaron@akamai.com> <92daa9c2-7bfc-94ff-bb06-91ef03cd0d66@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Baron <jbaron@akamai.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35944 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdAQTW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:22:56 -0500
Received: by mail-io0-f179.google.com with SMTP id j13so122658724iod.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:22:56 -0800 (PST)
In-Reply-To: <92daa9c2-7bfc-94ff-bb06-91ef03cd0d66@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 11:04 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>up unneeded resources in a more expedient fashion.
>
>
> Drifting a bit, and it doesn't change the value of dealing with it, but out
> of curiosity, when you say mostly in CLOSE_WAIT, why aren't the server-side
> applications reacting to the read return of zero triggered by the arrival of
> the FIN?

Even if the application reacts, and calls close(fd), kernel will still
try to push the data that was queued into socket write queue prior to
receiving the FIN.

By allowing this RST, we can flush the whole data and react much
faster, avoiding locking memory in the kernel for very long time.
