From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 22 May 2008 10:40:58 +0400
Message-ID: <20080522064058.GB7777@2ka.mipt.ru>
References: <a967d7d00805211835q241f8edai6253659330b8e6cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35907 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765553AbYEVGlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 02:41:14 -0400
Content-Disposition: inline
In-Reply-To: <a967d7d00805211835q241f8edai6253659330b8e6cf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, May 21, 2008 at 06:35:18PM -0700, Keyur Chudgar (kchudgar.linux@gmail.com) wrote:
> The way generally I saw this is done is,
> 1. Initially allocate skb with MTU size and configure ring buffer
> 2. If packet comes in multiple ring buffers, they copy these buffers
> and make a new single
> skb out of it
> 3. Send a single skb to netif_rx
> 
> The point 2 above can be done either using memcpy or DMA. But in any
> case, we need a copy.
> 
> Does anybody know, if there is a way, we can avoid the copy operation
> while a single packet
> received in multiple ring buffers?

Card can allocate list of pages and put data there, pages then can be
attached to skb. It is also possible to allocate new skb, put remainder
of the data there and chain skbs together, but it is not preffered way,
instead use fraglist of pages.

-- 
	Evgeniy Polyakov
