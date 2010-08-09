From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Mon, 9 Aug 2010 17:30:02 -0400
Message-ID: <20100809213002.GA23736@gondor.apana.org.au>
References: <20100806110511.GA16448@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37326 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756623Ab0HIVaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 17:30:07 -0400
Content-Disposition: inline
In-Reply-To: <20100806110511.GA16448@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:
> 
> While working on something else I noticed that tcp_v4/6_destroy_sock()
> can get called twice on a socket. This happens because when a reset or
> similar happens tcp_done destroys the connection socket state, and 
> then eventually when the socket is released it is destroyed again. 

I'm still having problems understanding why you're getting a call
to send a FIN after tcp_done.  This shouldn't happen at all because
tcp_done moves the socket to the TCP_CLOSE state, where FINs should
not be sent.

Can you clarify on how we can reproduce this problem in the
upstream kernel?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
