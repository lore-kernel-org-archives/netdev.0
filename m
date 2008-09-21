From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sun, 21 Sep 2008 10:13:47 +0100
Message-ID: <48D6104B.9040304@superbug.co.uk>
References: <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwalker@mvista.com,
	arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752687AbYIUJOL@vger.kernel.org>
In-Reply-To: <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
>> receive using multiple RX queues and MSI-X interrupts.  It's
>> also for things like IPSEC where the per-packet cpu usage
>> is so huge (to do the crypto) that it makes sense to even
>> split up the work to multiple cpus within the same flow.
> 
> Unfortunately doing this with IPsec is going to be non-trivial
> since we still want to maintain packet ordering inside IPsec
> and you don't get the inner flow information until you decrypt
> the packet.
> 

Why do you have to preserve packet ordering?
TCP/IP does not preserve packet ordering across the network.
IPSEC uses a sliding window for anti-relay detection precisely because
it has to be able to handle out-of-order packets.

Sharing the sliding window between CPUs might be interesting!

James
