From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 13:16:10 +0100
Message-ID: <20050124121610.GP23931@postel.suug.ch>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, kaber@trash.net,
        david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123202715.281ac87c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050123202715.281ac87c.davem@davemloft.net> 2005-01-23 20:27
> My current guess is that this is some successful exploit
> of some as-yet-unknown issue in netfilter's fragmentation
> handling.  But that's just a guess.  If some code underruns
> skb->data somehow while unfragging/refragging, that's a sure
> fire way to corrupt things such as the skb->ip_summed field.
> 
> All the theoretical attack has to do is find some way to
> copy a "1" into the byte at skb->ip_summed, as that's the
> value of CHECKSUM_HW.

It's more than that, to make it work on all nics, features
must be modified as well and it seems to happen. Besides
of that, there must be more corruption to ensure the checksum
gets calculated wrong, right? So why would one corrupt 3
places when it could be done a lot easier.

What is suspicious in the packet? The payload does indeed make
sense for DNS. The equal fragment offset for the two fragments
originating from two different hosts can also be explained.

It _does_ look like a bug in the fragmentation code but I'm not
sure if it really is triggered by some exploit.

> It would be nice to just log a full tcpdump trace for that
> UDP port on the incoming interface on that machine.  This
> will allow us to see the exact traffic pattern.

Yes, this might clear things up.

David, can you do this? and fix my patch by changing

	if (skb->h.raw < skb->data || skb->h.raw > skb->data)
into:
	if (skb->h.raw < skb->data || skb->h.raw > skb->tail)
