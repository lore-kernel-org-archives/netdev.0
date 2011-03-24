From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and avoid TX queue overrun through packet drop
Date: Thu, 24 Mar 2011 11:00:53 +1030
Message-ID: <87r59xbbr6.fsf@rustcorp.com.au>
References: <20110318133311.GA20623@gondor.apana.org.au> <1300498915.3441.21.camel@localhost.localdomain> <1300730587.3441.24.camel@localhost.localdomain> <20110322113649.GA17071@redhat.com> <1300847204.3441.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38111 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab1CXC6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 22:58:49 -0400
In-Reply-To: <1300847204.3441.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> With simply removing the notify here, it does help the case when TX
> overrun hits too often, for example for 1K message size, the single
> TCP_STREAM performance improved from 2.xGb/s to 4.xGb/s.

OK, we'll be getting rid of the "kick on full", so please delete that on
all benchmarks.

Now, does the capacity check before add_buf() still win anything?  I
can't see how unless we have some weird bug.

Once we've sorted that out, we should look at the more radical change
of publishing last_used and using that to intuit whether interrupts
should be sent.  If we're not careful with ordering and barriers that
could introduce more bugs.

Anything else on the optimization agenda I've missed?

Thanks,
Rusty.
