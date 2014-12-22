From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets in
 a single read with IFF_MULTI_READ
Date: Tue, 23 Dec 2014 09:34:36 +1100
Message-ID: <20141222223436.GA25970@gondor.apana.org.au>
References: <20141222120957.GA21319@gondor.apana.org.au>
 <54987C9F.5070103@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasonwang@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	herbert@gondor.apena.org.au, kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43073 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaLVWeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 17:34:44 -0500
Content-Disposition: inline
In-Reply-To: <54987C9F.5070103@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 12:18:39PM -0800, Alex Gartrell wrote:
> 
> While fully aware that this makes me look like an idiot, I have to
> admit that I've tried and failed to figure out how to get a socket
> fd out of the tun device.

Well right now the socket is only used within the kernel by
vhost so it's not exported to user-space.  If we were to use
recvmmsg obviously we'd create a new interface based on sockets
for tun and expose the existing socket through that.

The current file-based tun interface was never designed to be
a high-performance interface.  So let's take this opportunity
and create a new interface (but still using the same underlying
code since whatever you create should be easily applicable to
the existing kernel user vhost).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
