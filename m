From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 03 May 2012 07:19:33 +0200
Message-ID: <1336022373.12425.24.camel@edumazet-glaptop>
References: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>
	 <20120503033901.5482.27183.stgit@gitlad.jf.intel.com>
	 <1336017985.12425.9.camel@edumazet-glaptop>  <4FA21087.1080801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44241 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab2ECFTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 01:19:39 -0400
Received: by wibhr7 with SMTP id hr7so279679wib.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 22:19:38 -0700 (PDT)
In-Reply-To: <4FA21087.1080801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 21:58 -0700, Alexander Duyck wrote:
> The question I have is how can you get into a case where the ksize is 
> different from the end offset plus the aligned size of skb_shared_info?  
> From what I can tell it looks like the only place we can lie is if we 
> use build_skb with the frag_size option, and in that case we are using a 
> page, not kmalloc memory.  Otherwise in all other cases __alloc_skb or 
> build_skb is using ksize(skb->head) - SKB_DATA_ALIGN(struct 
> skb_shared_info) to set the end pointer, so reversing that should give 
> us the same value as ksize(skb->head).


Right after skb is allocated (build_skb() or other skb_alloc...
variants), truesize is correct by construction.

Then drivers add fragments and can make truesize smaller than reality.

And Intel drivers are known to abuse truesize.

My last patch against iwlwifi is still waiting to make its way into
official tree.

http://www.spinics.net/lists/netdev/msg192629.html
