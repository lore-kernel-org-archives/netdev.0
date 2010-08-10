From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Tue, 10 Aug 2010 06:39:31 -0400
Message-ID: <20100810103931.GA28438@gondor.apana.org.au>
References: <20100806110511.GA16448@basil.fritz.box> <20100809213002.GA23736@gondor.apana.org.au> <20100810083040.GB6801@basil.fritz.box> <20100810102421.GA28030@gondor.apana.org.au> <20100810103206.GC6801@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38359 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756884Ab0HJKje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 06:39:34 -0400
Content-Disposition: inline
In-Reply-To: <20100810103206.GC6801@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 12:32:06PM +0200, Andi Kleen wrote:
>
> Yes I stored the backtrace of the first caller in the ugly debug
> patches and dumped that on the second destroy. It was tcp_done the 
> first time.
> 
> Also did the same for tcp_sk() and there it was the fin sending.
> 
> I agree that tcp_close() should skip it in theory but I saw
> it anyways :/

So I presume the second caller was tcp_close? That means we have
a serious bug in our stack, as if the socket is already in the
CLOSE state then tcp_close should have short-circuited.

This means that something is changing the TCP socket state after
going into CLOSE.  Can you try adding your debug backtrace patch to
tcp_set_state to see if anybody is indeed changing the socket
state after going into CLOSE (and more importantly who is changing
it)?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
