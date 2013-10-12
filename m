From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Fri, 11 Oct 2013 18:20:19 -0700
Message-ID: <1381540819.4971.117.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131011.174858.1461090000704613432.davem@davemloft.net>
	 <1381531436.4971.114.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fitz@cs.yale.edu, ycheng@google.com,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:45683 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab3JLBU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 21:20:27 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so5162052pab.32
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 18:20:26 -0700 (PDT)
In-Reply-To: <1381531436.4971.114.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 15:43 -0700, Eric Dumazet wrote:
> On Fri, 2013-10-11 at 17:48 -0400, David Miller wrote:
> 
> > This patch is correct, so I've applied it, but it points out a bug.
> > 
> > The __tcp_retransmit_skb() code that does a __pskb_copy() to handle
> > NET_IP_ALIGN violations and skb_headroom() overflows is buggy because
> > it needs to store a congestion control timestamp in the original 'skb'
> > since that's what we'll look at in the retransmit queue.
> 
> Yes, I saw that, indeed.
> 
> I added it as low priority bug for the moment, as the default congestion
> module do not really care, and this case is really unlikely ;)
> 

Ah, I remember now that the conclusion was :
the timestamp is not taken into account for retransmits.

( FLAG_RETRANS_DATA_ACKED )
