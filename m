From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Tue, 10 Aug 2010 12:32:06 +0200
Message-ID: <20100810103206.GC6801@basil.fritz.box>
References: <20100806110511.GA16448@basil.fritz.box>
 <20100809213002.GA23736@gondor.apana.org.au>
 <20100810083040.GB6801@basil.fritz.box>
 <20100810102421.GA28030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49824 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab0HJKcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 06:32:11 -0400
Content-Disposition: inline
In-Reply-To: <20100810102421.GA28030@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 06:24:21AM -0400, Herbert Xu wrote:
> On Tue, Aug 10, 2010 at 10:30:40AM +0200, Andi Kleen wrote:
> . 
> > This simple patch demonstrates double destroy. I have patches for showing
> > the more complicated case too, but they're much more ugly.
> 
> Andi, I know you're seeing the problem, but I need to udnerstand
> why, and this patch doesn't really answer the why part :)
> 
> So did you figure out why was calling it first (I presume you
> know who called it the second time since you've got the back
> trace)?

Yes I stored the backtrace of the first caller in the ugly debug
patches and dumped that on the second destroy. It was tcp_done the 
first time.

Also did the same for tcp_sk() and there it was the fin sending.

I agree that tcp_close() should skip it in theory but I saw
it anyways :/

-Andi
