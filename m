From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 14:04:26 -0800
Message-ID: <20050114140426.5cf06f0c.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
	<20050113201914.46b7c4a2.davem@davemloft.net>
	<20050114111648.GA27964@gondor.apana.org.au>
	<20050114120322.GA28449@gondor.apana.org.au>
	<20050114110352.23c94ab9.davem@davemloft.net>
	<20050114203452.GA1277@gondor.apana.org.au>
	<20050114132757.4ca3153a.davem@davemloft.net>
	<20050114213829.GA12454@gondor.apana.org.au>
	<20050114133611.69ff0bb2.davem@davemloft.net>
	<20050114215504.GA12569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114215504.GA12569@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 08:55:04 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> As long as we're careful about what we've allocated in the skb then
> everything will be alright.  We're in trouble right now with mixed
> sendmsg/sendpages calls and changing MSSs only because we're not
> careful about keeping track of how much memory we've allocated
> at the start.

I see, but we don't want sendmsg() to charge a full MSS if the
user is only writing 10 bytes of data onto the wire.  That seems
to be what happens if we implement things the way you are suggesting.
