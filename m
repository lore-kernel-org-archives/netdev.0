From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] tcp: accept RST for rcv_nxt - 1 after receiving
 a FIN
Date: Tue, 17 Jan 2017 11:19:58 -0800
Message-ID: <6bbb94ef-9be6-6238-270b-fec5304a65c7@hpe.com>
References: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
 <92daa9c2-7bfc-94ff-bb06-91ef03cd0d66@hpe.com>
 <CANn89iJ-tc=m122UcEh9Xmuf1DoeKMwDf4Z42hWFZwxfRYFY_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Baron <jbaron@akamai.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:1829 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbdAQTUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:20:01 -0500
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com [15.241.48.72])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 360253A80
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 19:20:00 +0000 (UTC)
In-Reply-To: <CANn89iJ-tc=m122UcEh9Xmuf1DoeKMwDf4Z42hWFZwxfRYFY_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 11:13 AM, Eric Dumazet wrote:
> On Tue, Jan 17, 2017 at 11:04 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>> Drifting a bit, and it doesn't change the value of dealing with it, but out
>> of curiosity, when you say mostly in CLOSE_WAIT, why aren't the server-side
>> applications reacting to the read return of zero triggered by the arrival of
>> the FIN?
>
> Even if the application reacts, and calls close(fd), kernel will still
> try to push the data that was queued into socket write queue prior to
> receiving the FIN.
>
> By allowing this RST, we can flush the whole data and react much
> faster, avoiding locking memory in the kernel for very long time.

Understood.  I was just wondering if there is also an application bug here.

happy benchmarking,

rick jones
