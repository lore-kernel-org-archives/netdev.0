From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Mon, 29 Sep 2008 01:38:24 +0400
Message-ID: <20080928213824.GA25298@2ka.mipt.ru>
References: <20080928204633.GB19070@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:51525 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250AbYI1Vjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 17:39:49 -0400
Content-Disposition: inline
In-Reply-To: <20080928204633.GB19070@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lennert.

On Sun, Sep 28, 2008 at 10:46:33PM +0200, Lennert Buytenhek (buytenh@wantstofly.org) wrote:
> This patch adds skb_recycle_check(), which can be used by a network
> driver after transmitting an skb to check whether this skb can be
> recycled as a receive buffer.
> 
> skb_recycle_check() checks that the skb is not shared or cloned, and
> that it is linear and its head portion large enough (as determined by
> the driver) to be recycled as a receive buffer.  If these conditions
> are met, it does any necessary reference count dropping and cleans
> up the skbuff as if it just came from __alloc_skb().

Shouldn't it also perfrom all actions kfree_skb() does except actual
freeing, since given skb can be from socket, so it may leak dst entries
and break socket memory accounting?

-- 
	Evgeniy Polyakov
