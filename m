From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 19:11:52 -0700
Message-ID: <1366769512.8964.60.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	 <1366749094-5982-1-git-send-email-willemb@google.com>
	   <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	   <1366753063.8964.14.camel@edumazet-glaptop>
	   <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
	  <1366762196.8964.46.camel@edumazet-glaptop>
	 <517734A2.9060609@mojatatu.com> <1366767151.8964.56.camel@edumazet-glaptop>
	 <51773905.9030005@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:56078 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457Ab3DXCLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 22:11:55 -0400
Received: by mail-da0-f52.google.com with SMTP id j17so631174dan.39
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 19:11:54 -0700 (PDT)
In-Reply-To: <51773905.9030005@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 21:44 -0400, Jamal Hadi Salim wrote:

> 
> BTW, looking at __skb_get_rxhash(), if i had a driver that sets either
> skb->rxhash (picks it off the dma descriptor), could i not use that 
> instead of computing the hash? something like attached patch.
> 

The caller does this already ;)

static inline __u32 skb_get_rxhash(struct sk_buff *skb)
{
        if (!skb->l4_rxhash)
                __skb_get_rxhash(skb);

        return skb->rxhash;
}

Rationale being : if l4 rxhash was already provided, use it.

AFAIK, only bnx2x provides this.

For other cases, we prefer trying a software rxhash, as it gives us more
capabilities than the standard Toepliz hash (Not l4 for UDP flows for
example)
