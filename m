From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Sat, 10 Jul 2004 06:42:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709204228.GA3015@gondor.apana.org.au>
References: <20040709081443.GA11101@gondor.apana.org.au> <Xine.LNX.4.44.0407091001460.3887-100000@thoron.boston.redhat.com> <20040709123608.1f9f9265.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040709123608.1f9f9265.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 09, 2004 at 12:36:08PM -0700, David S. Miller wrote:
>
> > > If there are no objections, I'd like to create a version of
> > > skb_checksum_help() that doesn't copy the packet, and call
> > > that version from ah_output()/esp_output()/ipcomp_output().
> > 
> > This will break when cloned packets are passed to these functions.
> 
> James is right Herbert.  TCP will send clones down into these routines
> all the time.

The first TCP transmission will always be a clone of a packet off
its output queue.  However, the TCP code is written such that you
can modify any part of the skb except the TCP payload.  This
includes the TCP header which is where the TCP checksum is.

If this weren't the case then you'd have to copy the packet much earlier.
This assumption is already made by tcp_transmit_skb(), ip_queue_xmit()
and all the functions called by dst_output().

When TCP retransmits the packet, it will do a pskb_copy() on it so
it's no longer a clone.

So unless I've missed another case where someone will pass a clone
down, it is safe to change the checksum on the TCP clones.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
