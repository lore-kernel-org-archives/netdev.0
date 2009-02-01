From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 1 Feb 2009 20:40:25 +0300
Message-ID: <20090201174025.GA9562@ioremap.net>
References: <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net> <49841E8C.60401@cosmosbay.com> <20090131095640.GA29099@ioremap.net> <4984252B.8080508@cosmosbay.com> <20090201124220.GA2319@ioremap.net> <4985C9F9.1020103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:40737 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbZBARka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2009 12:40:30 -0500
Content-Disposition: inline
In-Reply-To: <4985C9F9.1020103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 01, 2009 at 05:12:41PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > David applied the patch which fixed the problem, so we can return to the
> > cache line issues. What do you think about the last version where
> > bsockets field was placed at the very end of the structure and with
> > cacheline_aligned_on_smp attribute?
> > 
> 
> Yes, at a minimum, move it away from first cache line.
> 
> And using atomic_t so that we dont have to discuss about accumulated
> errors on SMP on this variable. We will see later if percpu counter
> is wanted or not.
> 
> Thank you
> 
> [PATCH] net: move bsockets outside of read only beginning of struct inet_hashinfo
> 
> And switch bsockets to atomic_t since it might be changed in parallel.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Ok, let's do it this way. Ack.
Thank you Eric.

-- 
	Evgeniy Polyakov
