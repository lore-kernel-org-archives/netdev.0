From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 10:58:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407071013080.26759-100000@thoron.boston.redhat.com>
References: <20040707130652.GA26822@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040707130652.GA26822@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004, Herbert Xu wrote:

> In doing so I'm wondering why you changed dst->output to take a
> struct sk_buff ** from a struct sk_buff *.

This was because skb_checksum_help() was changed to potentially replace 
the skb in the output path.

>  All of the dst->output functions already assumed that they have
> exclusive access to the skb. This is justified because all callers to
> dst_output() makes sure that the packet is neither shared nor cloned.

Cloned skbs are regularly passed to dst_output(), thus we need to use the 
double pointer for skb_checksum_help() in case the skb is replaced.


- James
-- 
James Morris
<jmorris@redhat.com>
