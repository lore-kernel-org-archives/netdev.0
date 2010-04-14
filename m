From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Wed, 14 Apr 2010 08:58:22 +0800
Message-ID: <20100414005822.GD18044@gondor.apana.org.au>
References: <20100413145944.GA7716@redhat.com> <4BC48F79.5090409@siemens.com> <1271176838.16881.537.camel@edumazet-laptop> <20100413173919.GC26011@redhat.com> <1271183463.16881.545.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qemu-devel <qemu-devel@nongnu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59438 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752711Ab0DNA6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 20:58:41 -0400
Content-Disposition: inline
In-Reply-To: <1271183463.16881.545.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 08:31:03PM +0200, Eric Dumazet wrote:
>
> Herbert Acked your patch, so I guess its OK, but I think it can be
> dangerous.

The tun socket accounting was never designed to stop it from
flooding another tun interface.  It's there to stop it from
transmitting above a destination interface TX bandwidth and
cause unnecessary packet drops.  It also limits the total amount
of kernel memory that can be pinned down by a single tun interface.

In this case, all we're doing is shifting the accounting from the
"hardware" queue to the qdisc queue.

So your ability to flood a tun interface is essentially unchanged.

BTW we do the same thing in a number of hardware drivers, as well
as virtio-net.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
