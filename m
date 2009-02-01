From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 1 Feb 2009 15:42:20 +0300
Message-ID: <20090201124220.GA2319@ioremap.net>
References: <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net> <49841E8C.60401@cosmosbay.com> <20090131095640.GA29099@ioremap.net> <4984252B.8080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:34500 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbZBAMmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2009 07:42:22 -0500
Content-Disposition: inline
In-Reply-To: <4984252B.8080508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric.

On Sat, Jan 31, 2009 at 11:17:15AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> We only need to know if the *fix* is solving Stephen problem
> 
> About performance effects of careful variable placement and percpu counter
> strategy you might consult as an example :
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0812.1/01624.html

Impressive, but to be 100% fair it is not only because of the cache line
issues :)

> Now, with these patches applied, try to see effect of your new bsockets field
> on a network workload doing lot of socket bind()/unbind() calls...
> 
> With current kernels, you probably wont notice because of inode/dcache hot
> cache lines, but it might change eventually...

David applied the patch which fixed the problem, so we can return to the
cache line issues. What do you think about the last version where
bsockets field was placed at the very end of the structure and with
cacheline_aligned_on_smp attribute?

-- 
	Evgeniy Polyakov
