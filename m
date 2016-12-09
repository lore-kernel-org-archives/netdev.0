From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Fri, 9 Dec 2016 09:13:12 -0800
Message-ID: <CALx6S35HwvVBv=6=ZZMyOxe3gfXo-MR_VNL0syhn-pEWW1sxwA@mail.gmail.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
 <20161208214819.30138d12@redhat.com> <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161209170509.25347c9b@redhat.com> <1481300787.4930.198.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35roMkor_0maXk-SwdXeF4GxBfbxXLEXLGnn6mRRaut6g@mail.gmail.com> <1481302391.4930.201.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36041 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753980AbcLIRNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 12:13:14 -0500
Received: by mail-qk0-f195.google.com with SMTP id h201so2991023qke.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 09:13:14 -0800 (PST)
In-Reply-To: <1481302391.4930.201.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 8:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-12-09 at 08:43 -0800, Tom Herbert wrote:
>>
>>
>
>
>> Are you thinking of allowing unconnected socket to have multiple input
>> queues? Sort of an automatic and transparent SO_REUSEPORT...
>
> It all depends if the user application is using a single thread or
> multiple threads to drain the queue.
>
If they're using multiple threads hopefully there's no reason they
can't use SO_REUSEPORT. Since we should always assume DDOS is
possibility it seems like that should be a general recommendation: If
you have multiple threads listening on a port use SO_REUSEPORT.

> Since we used to grab socket lock in udp_recvmsg(), I guess nobody uses
> multiple threads to read packets from a single socket.
>
That's the hope! So the problem at hand is multiple producer CPUs and
one consumer CPU.

> So heavy users must use SO_REUSEPORT already, not sure what we would
> gain trying to go to a single socket, with the complexity of mem
> charging.
>
I think you're making a good point a the possibility that any
unconnected UDP socket could be subject to an attack, so any use of
unconnected UDP has the potential to become a "heavy user" (in fact
we've seen bring down whole networks before in production). Therefore
the single thread reader case is relevant to consider.

Tom

>
>>
>
>
