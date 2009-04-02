From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 2 Apr 2009 22:13:42 +0800
Message-ID: <20090402141342.GA377@gondor.apana.org.au>
References: <20090323.013749.122944803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, vernux@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46266 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757344AbZDBON7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 10:13:59 -0400
Content-Disposition: inline
In-Reply-To: <20090323.013749.122944803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 23 Mar 2009 09:32:39 +0100
> 
>> I dont understand, doesnt it defeat the ticket spinlock thing and fairness ?
>> 
>> Thread doing __qdisc_run() already owns the __QDISC_STATE_RUNNING bit.
> 
> Right.
> 
> Remember, the way this is designed is that if there is a busy
> cpu taking packets out of the queue and putting them into the
> device then other cpus will simply add to the queue and immediately
> return.  This effectively keeps the queue running there processing
> all the new work that other cpus are adding to the qdisc.
> 
> Those other cpus make these decisions by looking at that
> __QDISC_STATE_RUNNING bit, which the queue runner grabs before
> it does any work.

Come on guys, if this lock is a problem. go out and buy a proper
NIC that supports multiequeue TX!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
