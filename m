From: "David S. Miller" <davem@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 15:01:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707150132.5dc470b6.davem@redhat.com>
References: <20040707130652.GA26822@gondor.apana.org.au>
	<Xine.LNX.4.44.0407071013080.26759-100000@thoron.boston.redhat.com>
	<20040707212805.GA29899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040707212805.GA29899@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 07:28:05 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> OK.  Can you please tell me which caller of dst_output() passes
> a cloned skb to it?
> 
> I need to know this because if this is the case, we need fix the various
> IPsec output functions to copy the skb.

They do already, via skb_cow().

The case James's patch tries to deal with is when multicast
loops back packets to localhost, see ip_mc_output().
Since the SKB is a clone, if we do anything with the checksum
state of the clone, this messes up the hw checksumming state
of the original SKB and we get output packets with corrupt
checksums.
