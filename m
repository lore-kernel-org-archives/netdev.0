From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 22:22:51 -0700
Message-ID: <1473830571.22679.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
         <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
         <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
         <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35865 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755231AbcINFWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:22:53 -0400
Received: by mail-pf0-f170.google.com with SMTP id 128so1768671pfb.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 22:22:53 -0700 (PDT)
In-Reply-To: <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-13 at 22:13 -0700, Michael Ma wrote:

> I don't intend to install multiple qdisc - the only reason that I'm
> doing this now is to leverage MQ to workaround the lock contention,
> and based on the profile this all worked. However to simplify the way
> to setup HTB I wanted to use TXQ to partition HTB classes so that a
> HTB class only belongs to one TXQ, which also requires mapping skb to
> TXQ using some rules (here I'm using priority but I assume it's
> straightforward to use other information such as classid). And the
> problem I found here is that when using priority to infer the TXQ so
> that queue_mapping is changed, bandwidth is affected significantly -
> the only thing I can guess is that due to queue switch, there are more
> cache misses assuming processor cores have a static mapping to all the
> queues. Any suggestion on what to do next for the investigation?
> 
> I would also guess that this should be a common problem if anyone
> wants to use MQ+IFB to workaround the qdisc lock contention on the
> receiver side and classful qdisc is used on IFB, but haven't really
> found a similar thread here...

But why are you changing the queue ?

NIC already does the proper RSS thing, meaning all packets of one flow
should land on one RX queue. No need to ' classify yourself and risk
lock contention' 

I use IFB + MQ + netem every day, and it scales to 10 Mpps with no
problem.

Do you really need to rate limit flows ? Not clear what are your goals,
why for example you use HTB to begin with.
