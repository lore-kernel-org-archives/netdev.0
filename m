From: Alexander Sverdlin <alexander.sverdlin@gmail.com>
Subject: Re: [PATCH v2 net-next 06/12] ep93xx_eth: add GRO support
Date: Tue, 16 May 2017 22:41:28 +0200
Message-ID: <8ce1ad39-5f57-ecff-805d-0aaca6fbd138@gmail.com>
References: <20170204232502.22361-1-edumazet@google.com>
 <20170204232502.22361-7-edumazet@google.com>
 <20170515103132.GA24992@wantstofly.org> <591A12E8.1050603@gmail.com>
 <1494882170.2185.2.camel@Nokia-N900>
Reply-To: Alexander Sverdlin <alexander.sverdlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hartley Sweeten <hsweeten@visionengravers.com>
To: Ryan Mallon <rmallon@gmail.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35518 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdEPUlp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:41:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id v4so40744929wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:41:40 -0700 (PDT)
In-Reply-To: <1494882170.2185.2.camel@Nokia-N900>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

On 15/05/17 23:02, Alexander Sverdlin wrote:
>>> I don't know if we really care about this hardware anymore (I don't),
>>> but the ep93xx platform is still listed as being maintained in the
>>> MAINTAINERS file -- adding Ryan and Hartley.
>> I no longer have any ep93xx hardware to test with, and I never looked at
>> the Ethernet, so don't know the details. I think there are still a
>> handful of users. Adding Alexander who sent an ADC support series this
>> week, who might be able to test this?
> Yes, I very much care about ep93xx code being functional :)
> I'll test the patches tomorrow.

it turns out I've used this patch two weeks long already in 4.11; but I've spent
a couple of hours now torturing the new driver and was not able to provoke
any inadequate behavior. It either receives all packets in time or not at all.
If IRQs would be edge-triggered, I'd expect some stale packets, which do not
arrive at first, but then appear with the packets coming next. This is not
the case. I've used pktgen module for this, with minimal packets and
different bursts.

netperf shows 45Mbit/s on UDP_STREAM test, which is also fair amount for
200MHz CPU.

So, I see no problems with the change.
