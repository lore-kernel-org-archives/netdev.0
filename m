From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 08 Oct 2015 14:17:49 -0700
Message-ID: <1444339069.27760.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <1444318627-27883-2-git-send-email-edumazet@google.com>
	 <CALx6S36yCfq3Y36J2SwRtsKU5H6G2a=arJLVoUtjoPEdGAWJOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35245 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756536AbbJHVRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 17:17:51 -0400
Received: by pabve7 with SMTP id ve7so6413955pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 14:17:51 -0700 (PDT)
In-Reply-To: <CALx6S36yCfq3Y36J2SwRtsKU5H6G2a=arJLVoUtjoPEdGAWJOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 13:53 -0700, Tom Herbert wrote:

> If the incoming CPU is set for a connected UDP via
> sk_incoming_cpu_update, wouldn't this check subsequently _only_ allow
> packets for that socket to come from the same CPU?
> 

Hmm, I thought the SO_REUSEPORT path would be taken only for non
connected UDP sockets (like TCP listeners.).

But you might be right !

> Also, the check seems a little austere. Why not do something like:
> 
>                if (sk->sk_incoming_cpu != -1) {
>                        if (sk->sk_incoming_cpu != raw_smp_processor_id())
>                             score += 4;
>                }
> 
> My worry is that the packet steering configuration may change without
> the application's knowledge, so it's possible packets may come in on
> CPUs that the are unexpected to the application and then they would be
> dropped without matching a socket. I suppose that this could work with
> the original patch if a socket is bound to every CPU or there is at
> least one listener socket that is not bound to any CPU.

This is what I initially wrote, then I attempted a short cut, (abort
full list scan), then forgot to re-instate the first try, when I decided
to let this for future patch (Ying patch)

if (sk->sk_incoming_cpu == raw_smp_processor_id())
    score++;

(Note we do not even have to test for sk_incoming_cpu == -1 in this
variant)

I'll include this in v2.

Thanks.
