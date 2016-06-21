From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rxrpc: fix uninitialized variable use
Date: Tue, 21 Jun 2016 11:28:53 +0200
Message-ID: <6563611.x9M4D6kWiH@wuerfel>
References: <20160617095555.1696781-1-arnd@arndb.de> <3356.1466498932@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:62772 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcFUJ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 05:27:36 -0400
In-Reply-To: <3356.1466498932@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, June 21, 2016 9:48:52 AM CEST David Howells wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > Hashing the peer key was introduced for AF_INET, but gcc
> > warns about the rxrpc_peer_hash_key function returning uninitialized
> > data for any other value of srx->transport.family:
> > 
> > net/rxrpc/peer_object.c: In function 'rxrpc_peer_hash_key':
> > net/rxrpc/peer_object.c:57:15: error: 'p' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > 
> > Assuming that nothing else can be set here, this changes the
> > function to just return zero in case of an unknown address
> > family.
> 
> I'm actually more tempted to put a BUG() in there because if any new family
> support (say AF_INET6) is added, I want to make sure I catch all the places.

Makes sense. Do you want to do the patch yourself, or should I send
a new one doing that?

Maybe WARN() would be better than BUG()? That would still get the attention
it needs but not kill the process.

	Arnd
