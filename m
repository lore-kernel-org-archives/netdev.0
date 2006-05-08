From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Mon, 8 May 2006 23:51:32 +0400
Message-ID: <20060508195132.GB19091@2ka.mipt.ru>
References: <20060508122418.GA22554@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:61851 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751265AbWEHTwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 15:52:03 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060508122418.GA22554@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 08, 2006 at 04:24:22PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Luckily TCP processing is much more costly, e1000 interrupt handler
> is too big, there are a lot of context switches and other
> cache-unfriendly and locking stuff, but I still
> wonder where does 6 (!) times performance gain lives.

Since nocopy is actually equal to dma into mapped buffer,
so we get something close to 6 times less CPU usage, and if it can be
lineary transferred into performance gain, we found where the most
significant part of VJ channels lives. Unfortunately it is not backward
compatible with recv() system call, and requires major changes in
application to use this advantage.

-- 
	Evgeniy Polyakov
