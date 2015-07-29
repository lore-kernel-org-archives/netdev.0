From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 12:06:48 +0200
Message-ID: <1438164408.20182.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
	 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
	 <20150729091333.GB13113@pox.localdomain>
	 <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150729095416.GC13113@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34641 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbG2KGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 06:06:52 -0400
Received: by wibud3 with SMTP id ud3so213763925wib.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 03:06:51 -0700 (PDT)
In-Reply-To: <20150729095416.GC13113@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 11:54 +0200, Thomas Graf wrote:

> skb_set_hash_from_sk()
> skb_get_hash()
> 
> Am I misreading this? I'm not using SO_REUSEPORT and it might be OK
> to assume that different sockets may go to different queues even if
> the L4 tuple is identical.

skb_set_hash_from_sk() sets skb->hash in output path. Nothing uses it
then later. bonding uses its own hash functions.

SO_REUSEPORT is on input path, and uses its own hash anyway.
