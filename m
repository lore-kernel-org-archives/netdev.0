From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO + e1000
Date: Sun, 5 Dec 2004 21:18:07 -0800
Message-ID: <20041205211807.6f8622f6.davem@davemloft.net>
References: <20041205232226.GA5757@krispykreme.ozlabs.ibm.com>
	<E1Cb7dy-000588-00@gondolin.me.apana.org.au>
	<20041206041656.GE8751@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com,
        john.ronciak@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20041206041656.GE8751@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Dec 2004 15:16:56 +1100
Anton Blanchard <anton@samba.org> wrote:

> > This is a bug in e1000.  Even if it is required it isn't allowed to
> > modify a cloned packet.  It'll need to copy it so that other clone
> > users aren't affected.
> 
> It looks like the tg3 is doing a similar thing.

As does ixgb.

Most TSO drivers need to modify the IP header in
a similar way.  It has to do with how Microsoft's driver
API defines the TSO interface, which is what all the cards
implement.  They want the checksum field clear, and the
tot_len field of the IP header to be what the normal packets
will have.

Typhoon and S2IO seem to be a notable exceptions.
