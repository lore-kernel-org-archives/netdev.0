From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Thu, 8 Jul 2004 10:04:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708000421.GA30918@gondor.apana.org.au>
References: <20040707231221.GA30565@gondor.apana.org.au> <Xine.LNX.4.44.0407071931480.28863-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407071931480.28863-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 07:33:18PM -0400, James Morris wrote:
> 
> > So is there a caller to dst_output that does this as well?
> 
> The TCP code often clones skbs to be transmitted.

Thanks for the pointer.

I've looked at it and that appears to be safe.  The logic appears
to be that the first packet passed to dst_output() via ip_queue_xmit()
is a clone of the packet on the TCP output queue.  The output
functions are allowed to modify all parts of the skb except the
TCP payload.

Subsequent retransmits will unclone the packet before adding the
TCP header and passing it to ip_queue_xmit().

So the bottom line is that we don't have to unclone the packet before
touching the checksum in dst_output().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
