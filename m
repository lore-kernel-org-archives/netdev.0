From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Fri, 10 Aug 2007 22:07:27 +0200
Message-ID: <442f95ba19f8622ce04cf0334f34be11@kernel.crashing.org>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	csnook@redhat.com, rpjday@mindspring.com, netdev@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51136 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932648AbXHJULV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:11:21 -0400
In-Reply-To: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The compiler is within its rights to read a 32-bit quantity 16 bits at
>> at time, even on a 32-bit machine.  I would be glad to help pummel any
>> compiler writer that pulls such a dirty trick, but the C standard 
>> really
>> does permit this.
>
> Code all over the kernel assumes that 32-bit reads/writes
> are atomic so while such a compiler might be legal it certainly
> can't compile Linux.

That means GCC cannot compile Linux; it already optimises
some accesses to scalars to smaller accesses when it knows
it is allowed to.  Not often though, since it hardly ever
helps in the cost model it employs.


Segher

