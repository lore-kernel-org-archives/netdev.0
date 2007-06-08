From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 18:57:25 +0400
Message-ID: <20070608145724.GA14561@2ka.mipt.ru>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44386 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760903AbXFHO6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 10:58:23 -0400
Content-Disposition: inline
In-Reply-To: <20070608141452.GR7341@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 04:14:52PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> Here's a start, for the splice side at least of storing a buf-private
> entity with the ops.

:) I tested the same implementation, but I put skb pointer into
page->private. My approach is not correct, since the same page can hold
several objects, so if there are several splicers, this will scream.
I've tested your patch on top of splice-net branch, here is a result:

[   44.798853] Slab corruption: skbuff_head_cache start=ffff81003b726668, len=192
[   44.806148] Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
[   44.811598] Last user: [<ffffffff803699fd>](kfree_skbmem+0x7a/0x7e)
[   44.818012] 0b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6a 6b 6b a5
[   44.824889] Prev obj: start=ffff81003b726590, len=192
[   44.829985] Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
[   44.835604] Last user: [<ffffffff8036a22c>](__alloc_skb+0x40/0x13f)
[   44.842010] 000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[   44.848896] 010: 20 58 7e 3b 00 81 ff ff 00 00 00 00 00 00 00 00
[   44.855772] Next obj: start=ffff81003b726740, len=192
[   44.860868] Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
[   44.866314] Last user: [<ffffffff803699fd>](kfree_skbmem+0x7a/0x7e)
[   44.872721] 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
[   44.879597] 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b

I will try some things for the nearest 30-60 minutes, and then will move to
canoe trip until thuesday, so will not be able to work on this idea.

-- 
	Evgeniy Polyakov
