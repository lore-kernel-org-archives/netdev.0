From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sat, 11 Sep 2004 17:45:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911174535.2acbb957.davem@davemloft.net>
References: <20040908065152.GC27886@wotan.suse.de>
	<E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	<20040908072408.GI27886@wotan.suse.de>
	<1094629677.1089.155.camel@jzny.localdomain>
	<20040908134713.1bcd46d3.davem@davemloft.net>
	<1094823215.1121.129.camel@jzny.localdomain>
	<20040911142116.GL4431@wotan.suse.de>
	<1094933731.2343.109.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1094933731.2343.109.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 11 Sep 2004 16:15:32 -0400
jamal <hadi@cyberus.ca> wrote:

> If i was the one who had thought of the need for this new lock-riddance
> then i would have done it as follows:
> - have a devices xmit_lock as an alias to this other lock in case of
> NETIF_F_LLTX 
> Then you wouldnt have to touch this code. Infact if it is not too late
> why not do it like that?

If you turn dev->xmit_lock into a spinlock pointer, that would
incur much deeper changes across the tree than Andi's version
because there are a lot of xmit_lock explicit references out
there.

I think Andi made the right choice for his implementation.
And frankly I don't what is worrying about the
"-1" return value, it can occur in only one spot in a very
specific controlled case and it's behavior is incredibly well
defined (if not by accurate comments then by the code itself :-)
