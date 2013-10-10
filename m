From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: update mdb expiration timer upon reports.
Date: Fri, 11 Oct 2013 07:48:56 +0800
Message-ID: <20131010234856.GA31951@gondor.apana.org.au>
References: <1381435079-15387-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42363 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752083Ab3JJXtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 19:49:01 -0400
Content-Disposition: inline
In-Reply-To: <1381435079-15387-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 03:57:59PM -0400, Vlad Yasevich wrote:
> commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b
> 	bridge: only expire the mdb entry when query is received
> changed the mdb expiration timer to be armed only when QUERY is
> received.  Howerver, this causes issues in an environment where
> the multicast server socket comes and goes very fast while a client
> is trying to send traffic to it.
> 
> The root cause is a race where a sequence of LEAVE followed by REPORT
> messages can race against QUERY messages generated in response to LEAVE.
> The QUERY ends up starting the expiration timer, and that timer can
> potentially expire after the new REPORT message has been received signaling
> the new join operation.  This leads to a significant drop in multicast
> traffic and possible complete stall. 
> 
> The solution is to have REPORT messages update the expiration timer
> on entries that already exist.
> 
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Good catch.  Thanks!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
