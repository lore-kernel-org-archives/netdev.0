From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
 external.
Date: Sun, 20 Jun 2010 16:19:14 +0100
Message-ID: <1277047154.14011.880.camel@localhost>
References: <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com>
	 <20100618055929.GA11333@gondor.apana.org.au>
	 <F2E9EB7348B8264F86B6AB8151CE2D7915089FE573@shsmsx502.ccr.corp.intel.com>
	 <20100620100631.GB4578@redhat.com>
	 <20100620103235.GA31284@gondor.apana.org.au>
	 <20100620103909.GA5285@redhat.com>
	 <20100620110254.GA31484@gondor.apana.org.au>
	 <20100620111124.GB5285@redhat.com>
	 <20100620113609.GA31693@gondor.apana.org.au>
	 <20100620114719.GC5285@redhat.com>
	 <20100620115926.GA31849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47211 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226Ab0FTPTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 11:19:20 -0400
In-Reply-To: <20100620115926.GA31849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-20 at 21:59 +1000, Herbert Xu wrote:
> On Sun, Jun 20, 2010 at 02:47:19PM +0300, Michael S. Tsirkin wrote:
> >
> > Let's do this then.  So far the virtio spec avoided making layout
> > assumptions, leaving guests lay out data as they see fit.
> > Isn't it possible to keep supporting this with zero copy for hardware
> > that can issue DMA at arbitrary addresses?
> 
> I think you're mistaken with respect to what is being proposed.
> Raising 512 bytes isn't a hard constraint, it is merely an
> optimisation for Intel NICs because their PS mode can produce
> a head fragment of up to 512 bytes.
> 
> If the guest didn't allocate 512 bytes it wouldn't be the end of
> the world, it'd just mean that we'd either copy whatever is in
> the head fragment, or we waste 4096-X bytes of memory where X
> is the number of bytes in the head.

If I understand correctly what this 'PS mode' is (I haven't seen the
documentation for it), it is a feature that Microsoft requested from
hardware vendors for use in Hyper-V.  As a result, the SFC9000 family
and presumably other controllers also implement something similar.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

