From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Fri, 31 Dec 2004 09:33:52 +0100
Message-ID: <20041231083352.GA25031@xi.wantstofly.org>
References: <1104432914.15601.19.camel@localhost.localdomain> <20041230222415.GB19587@xi.wantstofly.org> <1104448248.15601.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        snort2004@mail.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1104448248.15601.55.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 31, 2004 at 12:10:48AM +0100, Bart De Schuymer wrote:

> > A while ago there were a number of problems with bridging CIPE ethernet
> > devices, which turned out to be the bridge code not initialising
> > skb->protocol for locally originated STP frames.
> > 
> > At the time I was told that initialising skb->protocol for locally
> > originated packets is required, so that is how I fixed it then.
> 
> Hi Lennert,

Hello,


> skb->protocol is not set for locally generated packets when the packet
> is still in the IP stack. I don't know what happens with it after the IP
> stack is finished with the packet.
> The comment in skbuff.h says "packet protocol from driver", from which I
> tend to conclude that skb->protocol is only set by drivers when a packet
> enters the box.
> Too bad stuff like this isn't clearly spelled out,

This is what I thought back then too.  Indeed, it's rather misleading.


> the FIXME for the dst field has been sitting there for probably more
> than a year too.

Yes :(

Just one more thing: AFAIK it is possible to inject a raw IPv4 packet
with an invalid IPv4 header.  So maybe the better 'fix' would be to have
different hooks for PF_INET and PF_INET6, and distinguish v4/v6 packets
that way instead of peeking into the header.  (The hook you're talking
about is a PF_INET* and not a PF_BRIDGE hook, right?)

Then again, that would add yet another function onto the already rather
deep call chains that we have in there.

Too bad I don't see any cleaner way of integrating the whole bridging
thing into the stack.  I wonder if any of the *BSDs found a cleaner way
of doing this.


--L
