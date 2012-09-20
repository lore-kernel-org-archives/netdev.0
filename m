From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 11:37:22 -0700
Message-ID: <CAK6E8=fSfN-okP9YbYA994cQnXUtCxeXEtZT5a3MVcXf0GhjnA@mail.gmail.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
 <1347901326.26523.149.camel@edumazet-glaptop> <1347901493.26523.151.camel@edumazet-glaptop>
 <20120917.130732.1894375657044880827.davem@davemloft.net> <1348067659.26523.949.camel@edumazet-glaptop>
 <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
 <1348119475.31352.60.camel@edumazet-glaptop> <505B4E13.5000501@hp.com> <1348163031.3440.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rick Jones <rick.jones2@hp.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:39005 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab2ITShn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 14:37:43 -0400
Received: by oago6 with SMTP id o6so2511958oag.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 11:37:43 -0700 (PDT)
In-Reply-To: <1348163031.3440.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 10:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-09-20 at 10:10 -0700, Rick Jones wrote:
>> On 09/19/2012 10:37 PM, Eric Dumazet wrote:
>> > loopback is lossless, so its always surprising we can have TCP
>> > retransmits on this medium ;)
>>
>> Is it lossless?
>>
>
> It is lossless, yes.
>
> But packets can be dropped by TCP stack for various reasons, including
> reordering and retransmits.
I'd recommend checking reordering stats. If it's lose less, set
tp->reordering = 127 for loopback.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
