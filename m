From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 12:23:31 +0200
Message-ID: <20071010102331.GA10496@one.firstfloor.org>
References: <20071010003716.GB552@one.firstfloor.org> <20071009.175025.59469417.davem@davemloft.net> <20071010091644.GA9807@one.firstfloor.org> <20071010.022550.21928751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, jeff@garzik.org,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46678 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbXJJKXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 06:23:34 -0400
Content-Disposition: inline
In-Reply-To: <20071010.022550.21928751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2007 at 02:25:50AM -0700, David Miller wrote:
> The chip I was working with at the time (UltraSPARC-IIi) compressed
> all the linear stores into 64-byte full cacheline transactions via
> the store buffer.

That's a pretty old CPU. Conclusions on more modern ones might be different.

> In fact, such a thing might not pan out well, because most of the time
> you write a single descriptor or two, and that isn't a full cacheline,
> which means a read/modify/write is the only coherent way to make such
> a write to RAM.

x86 WC does R-M-W and is coherent of course. The main difference is 
just that the result is not cached.  When the hardware accesses the cache line
then the cache should be also invalidated.

> Sure you could batch, but I'd rather give the chip work to do unless
> I unequivocably knew I'd have enough pending to fill a cacheline's
> worth of descriptors.  And since you suggest we shouldn't queue in
> software... :-)

Hmm, it probably would need to be coupled with batched submission if 
multiple packets are available you're right. Probably not worth doing explicit
queueing though.

I suppose it would be an interesting experiment at least.

-Andi
