From: Ben Greear <greearb@candelatech.com>
Subject: Re: Interconnect virtual device?
Date: Wed, 02 Mar 2005 14:34:18 -0800
Message-ID: <42263F6A.3020405@candelatech.com>
References: <4222A8F2.6080004@candelatech.com>	 <1109592365.2188.914.camel@jzny.localdomain>	 <422353C9.6050001@candelatech.com> <1109800554.1091.213.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1109800554.1091.213.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> There are two ways to do this:
> 
> a) You could redirect to a packet socket - a small extension needed to
> the redirect action (mostly mechanical details involved like keeping
> state of which sockets are open etc).

I'd rather not take this approach, as I'd like to have this
functionality available in a kernel module as well as user-space.  Netdevices
are easy to work with in both user-space and kernel-space.

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
> 
> Assuming you have a program running on user space you should receive all
> packets incoming and/or outgoing on eth0.
> 
> And no, you dont need the eth device to have a ip address attached.

Just mirror-ing will not meet my goal.  I may also wish to drop packets
entirely, before they ever reach any of the protocol stacks.

That said, a brief glance at the ntop page leads me to believe that
his packet socket might be interesting for other reasons.  But, I have
enough fun trying to push my own stuff into the kernel... probably
won't bother trying to push his stuff in too :)

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
