From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Tue, 21 Apr 2015 17:09:09 -0700
Message-ID: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
		<20150320.132029.103306583158863864.davem@davemloft.net>
		<550C5A98.5040305@akamai.com>
	 <20150324.021050.384709317309031128.davem@davemloft.net>
	 <55110009.4020706@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34836 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964887AbbDVAJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:09:11 -0400
Received: by igbyr2 with SMTP id yr2so100993382igb.0
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 17:09:10 -0700 (PDT)
In-Reply-To: <55110009.4020706@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-24 at 01:11 -0500, Josh Hunt wrote:
> On 03/24/2015 01:10 AM, David Miller wrote:
> > From: Josh Hunt <johunt@akamai.com>
> > Date: Fri, 20 Mar 2015 12:36:24 -0500
> >
> >> Would it be possible to queue up 355a901e6cf1 (tcp: make connect()
> >> mem charging friendly) for stable as well? That is the commit that
> >> fixes this problem in the tcp_connect()/tcp_send_syn_data() cases.
> >
> > Done.
> >
> 
> Thanks David.

Note that this patch adds a deadlock possibility in some stress
situations.

If a process owning some tcp socket dies, and tcp_mem[2] is already hit,
all sk_stream_alloc_skb() can return NULL and we loop in tcp_send_fin(),
making no progress because we can not free any tcp memory.
