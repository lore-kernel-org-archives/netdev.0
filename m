From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss >
 window)
Date: Fri, 13 Jan 2017 20:07:12 +0300
Message-ID: <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33082 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdAMRHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:07:47 -0500
In-Reply-To: <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
On 13.01.2017 18:35, Eric Dumazet wrote:
> On Fri, 2017-01-13 at 18:01 +0300, Alexey Kodanev wrote:
>> Hi,
>>
>> Got the issue when running LTP/netstress test on localhost with mss
>> greater than the send window advertised by client (right after 3WHS).
>> Here is the testscenario that can reproduce this:
> Hi Alexey
>
> So this is a combination of Fastopen + small window + large MSS ?

Yeah, this happens only in the beginning, after first ack from client.
Later window gets
lager than mss and it doesn't happen.

>
> I would rather not force burning tons of coal or other fossil fuel,
> by making each tcp_sendmsg() done by billions of linux devices more
> expensive, only to accommodate for some LTP test doing something not
> sensible ;)
>
> Fact that you removed one condition in the BUG_ON() might hide another
> issue later in the path.
>
> I would suggest to clamp MSS to half the initial window, but I guess
> this is impractical since window in SYN/SYNACK are not scaled.
> Care to send a packetdrill test so that we have a clear picture of what
> is going on ?

Is it capable of making two connections in the single test, one after
another?

Thanks,
Alexey
