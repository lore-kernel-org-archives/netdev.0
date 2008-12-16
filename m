From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
	communication.
Date: Tue, 16 Dec 2008 08:57:27 +0200
Message-ID: <20081216065727.GD13794@redhat.com>
References: <4946717F.2090809@codemonkey.ws> <20081215.114315.165733593.davem@davemloft.net> <4946C1AA.4080404@codemonkey.ws> <20081215.142918.190909950.davem@davemloft.net> <4946E1BA.80206@codemonkey.ws> <20081215234511.GA24579@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39406 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbYLPG5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 01:57:24 -0500
Content-Disposition: inline
In-Reply-To: <20081215234511.GA24579@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2008 at 02:45:11AM +0300, Evgeniy Polyakov wrote:
> Hi Anthony.
> 
> On Mon, Dec 15, 2008 at 05:01:14PM -0600, Anthony Liguori (anthony@codemonkey.ws) wrote:
> > Yes, and I went down the road of using a dedicated network device and 
> > using raw ethernet as the protocol.  The thing that killed that was the 
> > fact that it's not reliable.  You need something like TCP to add 
> > reliability.
> > 
> > But that's a lot of work and a bit backwards.  Use a unreliable 
> > transport but use TCP on top of it to get reliability.  Our link 
> > (virtio) is inherently reliable so why not just expose a reliable 
> > interface to userspace?
> 
> I removed original mail and did not check archive, but doesn't rx/tx
> queues of the virtio device have limited size? I do hope they have,
> which means that either your network drops packets or blocks.
> 
It blocks.

> Another approach is to implement that virtio backend with netlink based
> userspace interface (like using connector or genetlink). This does not
> differ too much from what you have with special socket family, but at
> least it does not duplicate existing functionality of
> userspace-kernelspace communications.
> 
I implemented vmchannel using connector initially (the downside is that
message can be dropped). Is this more expectable for upstream? The
implementation was 300 lines of code.

--
			Gleb.
