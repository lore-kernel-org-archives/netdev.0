From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Interconnect virtual device?
Date: Wed, 2 Mar 2005 23:55:58 +0100
Message-ID: <20050302225558.GS31837@postel.suug.ch>
References: <4222A8F2.6080004@candelatech.com> <1109592365.2188.914.camel@jzny.localdomain> <422353C9.6050001@candelatech.com> <1109800554.1091.213.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1109800554.1091.213.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> b) My preference is to push this gentleman's PF_RING
> (http://www.ntop.org/ntop.html) netdevice into the kernel. He has
> replicated unfortunately a lot of the stuff already done by MMAPED
> packet socket - but i think we can forgive him since solution a) would
> require hacking packet socket.
> 
> Reinjection of packets still needs working for that device - just as
> much as a few cleanups here and there. The problem is the guy is not
> very responsive - I have a lot of notes on his stuff if you are willing
> to chase him around.
> You can then get redirection to this device for free (for either
> incoming or outgoing packets); something like:
> 
> tc filter add dev eth0 .... \
> match ip src 10.0.0.1/32 \
> action mirred egress redirect dev ring0

I think we talked about this once already and I do like the idea
but the reinjection is at least of the same importance to me. What
I'm thinking of basically gets down to two ring buffers both holding
mmaped buffers. The action enqueues skbs to the first ring buffer
and userspace dequeues it from there. The skb gets completely lost
at this point by having it shot or just cloned if mirroring is requested.
Userspace may reinject the skb again by putting it onto the second
ring buffer for a kernel thread to pick up and reinject it at
netif_receive_skb. Userspace may do whathever it likes as long as
the checksum gets corrected, it may also fragment packets and reinject
more than it originally received. Obviously for the redirect to
userspace the skb must fullfil quite a lot of requirements only
achievable on ingress but it would open up possibilities quite a lot.
