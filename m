From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Thu, 10 Jun 2010 07:49:12 -0700
Message-ID: <20100610074912.1303e3da@nehalam>
References: <20100610124047.GA16658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56045 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753773Ab0FJOtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 10:49:19 -0400
In-Reply-To: <20100610124047.GA16658@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jun 2010 22:40:47 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi:
> 
> Qianfeng Zhang reported that he was seeing crashes with the
> attached backtrace.
> 
> I tracked this down to the recently added netpoll support in
> the bridge device.  It's a classic use-after-free problem.
> 
> Trying to solve it brought out a host of other issues, some of
> which existed prior to the new bridge code.  The following patches
> attempt to address some of these issues.
> 
> Warning, this is completely untested (apart from compiling with
> everything enabled) so please look but don't merge :)

Thanks for looking at this, and yes the original code does
look buggy. Not sure if I like the use of in_irq() to handle the netpoll
packets as special case. Is in_irq() really reliable for this?
