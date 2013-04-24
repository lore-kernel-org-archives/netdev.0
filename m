From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Wed, 24 Apr 2013 07:41:04 -0700
Message-ID: <1366814464.8964.64.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	  <1366749094-5982-1-git-send-email-willemb@google.com>
	    <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	    <1366753063.8964.14.camel@edumazet-glaptop>
	    <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
	   <1366762196.8964.46.camel@edumazet-glaptop>
	  <517734A2.9060609@mojatatu.com>
	 <1366767151.8964.56.camel@edumazet-glaptop>
	  <51773905.9030005@mojatatu.com>
	 <1366769512.8964.60.camel@edumazet-glaptop> <5177D771.6050307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60806 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab3DXOlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 10:41:08 -0400
Received: by mail-pb0-f46.google.com with SMTP id xa7so478784pbc.19
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 07:41:06 -0700 (PDT)
In-Reply-To: <5177D771.6050307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 09:00 -0400, Jamal Hadi Salim wrote:
> I forgot about the Toepliz hash connection. I can see it makes sense here.
> 
> Let me clarify:
> In the scenario i am thinking of, I have clever hardware which is smart 
> enough to deal with details of identifying flow state(including 
> fragementation etc) and tagging it in a DMA descriptor with 32 bit id.
> I want to be able to take the tag produced by the hardware and use
> that for rps cpu selection i.e assume the hardware has already done the
> hashing and is giving me a 32 bit id. My initial thought was skb->rxhash
> is the right spot to store this; then make get_rps_cpu() do the
> selection based on this. l4 rxhash is 1 bit which is too small.

Set skb->rxrhash to the hash your hardware computed, and skb->l4_rxhash
to 1.

Then get_rps_cpu() will use skb->rxhash happily

(and other callers of skb_get_rxhash() as well)

Not clear what you mean by fragmentation : fragmented frames have no
flow information (but the first fragment)
