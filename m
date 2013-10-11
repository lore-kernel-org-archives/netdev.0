From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: update mdb expiration timer upon reports.
Date: Fri, 11 Oct 2013 00:57:30 -0400 (EDT)
Message-ID: <20131011.005730.1355286910518558752.davem@davemloft.net>
References: <1381435079-15387-1-git-send-email-vyasevic@redhat.com>
	<20131010234856.GA31951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, stephen@networkplumber.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab3JKE5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 00:57:31 -0400
In-Reply-To: <20131010234856.GA31951@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 11 Oct 2013 07:48:56 +0800

> On Thu, Oct 10, 2013 at 03:57:59PM -0400, Vlad Yasevich wrote:
>> commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b
>> 	bridge: only expire the mdb entry when query is received
>> changed the mdb expiration timer to be armed only when QUERY is
>> received.  Howerver, this causes issues in an environment where
>> the multicast server socket comes and goes very fast while a client
>> is trying to send traffic to it.
>> 
>> The root cause is a race where a sequence of LEAVE followed by REPORT
>> messages can race against QUERY messages generated in response to LEAVE.
>> The QUERY ends up starting the expiration timer, and that timer can
>> potentially expire after the new REPORT message has been received signaling
>> the new join operation.  This leads to a significant drop in multicast
>> traffic and possible complete stall. 
>> 
>> The solution is to have REPORT messages update the expiration timer
>> on entries that already exist.
>> 
>> CC: Cong Wang <xiyou.wangcong@gmail.com>
>> CC: Herbert Xu <herbert@gondor.apana.org.au>
>> CC: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> Good catch.  Thanks!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and queued up for -stable, thanks everyone.
