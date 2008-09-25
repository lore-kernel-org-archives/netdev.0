From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Using skb_get() to recycle skbs
Date: Thu, 25 Sep 2008 18:28:33 +0400
Message-ID: <20080925142833.GA15185@2ka.mipt.ru>
References: <20080922002153.GC1878@2ka.mipt.ru> <20080921.174450.20349529.davem@davemloft.net> <20080922010834.GB3059@2ka.mipt.ru> <20080921.190715.144340989.davem@davemloft.net> <20080922041929.GA20165@2ka.mipt.ru> <A4114C1019D2F34CA5D6CDF8A4D1890178BEB834A0@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ram.Natarajan@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39866 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbYIYO3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 10:29:23 -0400
Content-Disposition: inline
In-Reply-To: <A4114C1019D2F34CA5D6CDF8A4D1890178BEB834A0@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Sep 25, 2008 at 06:03:03AM -0700, Ram.Natarajan@Emulex.Com (Ram.Natarajan@Emulex.Com) wrote:
> In our netdev driver, we preallocate a pool of skb which are
> used by our h/w to DMA frames.
> 
> Normally, when we indicate a packet to stack (netif_rx),
> the stack ends up freeing it. If we do a skb_get() prior
> to that, then the stack just reduces the use_count,
> and our driver is able to re-use it. We do have to use
> caution to see that stack has dropped it's reference
> (atomic_read(skb->users) <= 1) prior to returning
> the buffer to our h/w.
> 
> Is this a valid approach? It so it could save some
> CPU cycles which are used in alloc_skb(). If this
> can be done, how come more drivers in tree are not
> doing it, is there any flip side to it? One could be
> that stack may not free it in time (we could starve
> the hardware of free buffers), but in that case
> we can drop our reference, and let the stack
> free it up, and force an allocation instead of
> reuse.

Now stack allocates new skb and copy data from old one to the new, since
it belives that skb is shared between different users and thus can not
be modified in the rx path. You can check how skb_share_check() is
called in ip_rcv() and similar receiving functions.

-- 
	Evgeniy Polyakov
