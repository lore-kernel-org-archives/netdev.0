From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 11:54:16 +0200
Message-ID: <20150729095416.GC13113@pox.localdomain>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
 <20150729091333.GB13113@pox.localdomain>
 <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37246 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbbG2JyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:54:19 -0400
Received: by wibud3 with SMTP id ud3so18279346wib.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:54:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/15 at 11:29am, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 11:13 +0200, Thomas Graf wrote:
> > On 07/28/15 at 04:02pm, Tom Herbert wrote:
> > > This patch creates sk_set_txhash and eliminates protocol specific
> > > inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
> > > random number instead of performing flow dissection. sk_set_txash
> > > is also allowed to be called multiple times for the same socket,
> > > we'll need this when redoing the hash for negative routing advice.
> > > 
> > > Signed-off-by: Tom Herbert <tom@herbertland.com>
> > 
> > Doesn't this break TX hashing with SO_REUSEPORT?
> 
> 
> AFAIK nothing uses sk_txhash yet.

skb_set_hash_from_sk()
skb_get_hash()

Am I misreading this? I'm not using SO_REUSEPORT and it might be OK
to assume that different sockets may go to different queues even if
the L4 tuple is identical.
