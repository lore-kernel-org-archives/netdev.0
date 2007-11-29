From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] Fix inet_diag.ko register vs rcv race
Date: Thu, 29 Nov 2007 10:47:17 -0200
Message-ID: <20071129124717.GD12069@ghostprotocols.net>
References: <474C1717.4040607@openvz.org> <20071129123733.GC30420@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755959AbXK2MrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 07:47:25 -0500
Content-Disposition: inline
In-Reply-To: <20071129123733.GC30420@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Nov 29, 2007 at 11:37:34PM +1100, Herbert Xu escreveu:
> On Tue, Nov 27, 2007 at 04:09:43PM +0300, Pavel Emelyanov wrote:
> > The following race is possible when one cpu unregisters the handler
> > while other one is trying to receive a message and call this one:
> 
> Good catch! But I think we need a bit more to close this fully.
> 
> Dumps can resume asynchronously which means that they won't be
> holding inet_diag_mutex.  We can fix that pretty easily by
> giving that as our cb_mutex.
> 
> So could you add that to your patch and resubmit?
> 
> Arnaldo, synchronize_rcu() doesn't work on its own.  Whoever accesses
> the object that it's supposed to protect has to use the correct RCU
> primitives for this to work.
> 
> Synchronisation is like tango, it always takes two to make it work :)

Agreed, I didn't checked that when refactoring inet_diag, leaving this
as it was before I put my hands on it :-)

- Arnaldo
