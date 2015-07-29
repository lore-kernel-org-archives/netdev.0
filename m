From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 12:47:37 +0200
Message-ID: <20150729104737.GD13113@pox.localdomain>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
 <20150729091333.GB13113@pox.localdomain>
 <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150729095416.GC13113@pox.localdomain>
 <1438164408.20182.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34573 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbG2Krl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:47:41 -0400
Received: by wibud3 with SMTP id ud3so215106467wib.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 03:47:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438164408.20182.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/15 at 12:06pm, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 11:54 +0200, Thomas Graf wrote:
> 
> > skb_set_hash_from_sk()
> > skb_get_hash()
> > 
> > Am I misreading this? I'm not using SO_REUSEPORT and it might be OK
> > to assume that different sockets may go to different queues even if
> > the L4 tuple is identical.
> 
> skb_set_hash_from_sk() sets skb->hash in output path. Nothing uses it
> then later. bonding uses its own hash functions.
> 
> SO_REUSEPORT is on input path, and uses its own hash anyway.

Yes, I'm talking about the output path only but after further reading,
the only case that could be a problem is if two SO_REUSEPORT sockets
connect to the same destination address and port which will be prevented
by connect anyway.
