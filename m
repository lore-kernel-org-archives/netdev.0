From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Fri, 11 Oct 2013 15:43:56 -0700
Message-ID: <1381531436.4971.114.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131011.174858.1461090000704613432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fitz@cs.yale.edu, ycheng@google.com,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50095 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab3JKWoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 18:44:01 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so5042726pab.11
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 15:44:00 -0700 (PDT)
In-Reply-To: <20131011.174858.1461090000704613432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 17:48 -0400, David Miller wrote:

> This patch is correct, so I've applied it, but it points out a bug.
> 
> The __tcp_retransmit_skb() code that does a __pskb_copy() to handle
> NET_IP_ALIGN violations and skb_headroom() overflows is buggy because
> it needs to store a congestion control timestamp in the original 'skb'
> since that's what we'll look at in the retransmit queue.

Yes, I saw that, indeed.

I added it as low priority bug for the moment, as the default congestion
module do not really care, and this case is really unlikely ;)
