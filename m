From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Sun, 28 Sep 2008 23:50:35 +0200
Message-ID: <20080928215035.GG19070@xi.wantstofly.org>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:46385 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbYI1Vuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 17:50:39 -0400
Content-Disposition: inline
In-Reply-To: <20080928213824.GA25298@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 01:38:24AM +0400, Evgeniy Polyakov wrote:

> Hi Lennert.

Hi,


> > This patch adds skb_recycle_check(), which can be used by a network
> > driver after transmitting an skb to check whether this skb can be
> > recycled as a receive buffer.
> > 
> > skb_recycle_check() checks that the skb is not shared or cloned, and
> > that it is linear and its head portion large enough (as determined by
> > the driver) to be recycled as a receive buffer.  If these conditions
> > are met, it does any necessary reference count dropping and cleans
> > up the skbuff as if it just came from __alloc_skb().
> 
> Shouldn't it also perfrom all actions kfree_skb() does except actual
> freeing, since given skb can be from socket, so it may leak dst entries
> and break socket memory accounting?

Doesn't it?  It calls skb_release_head_state() (new function), which
should do that.


cheers,
Lennert
