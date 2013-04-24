From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Wed, 24 Apr 2013 09:00:33 -0400
Message-ID: <5177D771.6050307@mojatatu.com>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>  <1366749094-5982-1-git-send-email-willemb@google.com>    <20130423142333.15479dfa@nehalam.linuxnetplumber.net>    <1366753063.8964.14.camel@edumazet-glaptop>    <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>   <1366762196.8964.46.camel@edumazet-glaptop>  <517734A2.9060609@mojatatu.com> <1366767151.8964.56.camel@edumazet-glaptop>  <51773905.9030005@mojatatu.com> <1366769512.8964.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:63385 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab3DXNAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 09:00:37 -0400
Received: by mail-ob0-f179.google.com with SMTP id oi10so1380141obb.10
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 06:00:36 -0700 (PDT)
In-Reply-To: <1366769512.8964.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-23 10:11 PM, Eric Dumazet wrote:

>
> The caller does this already ;)

[..]
>
> Rationale being : if l4 rxhash was already provided, use it.
>
> AFAIK, only bnx2x provides this.
>
 > For other cases, we prefer trying a software rxhash, as it gives us
 > more
 > capabilities than the standard Toepliz hash (Not l4 for UDP flows for
 > example)
 >


I forgot about the Toepliz hash connection. I can see it makes sense here.

Let me clarify:
In the scenario i am thinking of, I have clever hardware which is smart 
enough to deal with details of identifying flow state(including 
fragementation etc) and tagging it in a DMA descriptor with 32 bit id.
I want to be able to take the tag produced by the hardware and use
that for rps cpu selection i.e assume the hardware has already done the
hashing and is giving me a 32 bit id. My initial thought was skb->rxhash
is the right spot to store this; then make get_rps_cpu() do the
selection based on this. l4 rxhash is 1 bit which is too small.

cheers,
jamal
