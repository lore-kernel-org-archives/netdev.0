From: jamal <hadi@cyberus.ca>
Subject: Re: Interconnect virtual device?
Date: 02 Mar 2005 19:27:05 -0500
Message-ID: <1109809625.1092.239.camel@jzny.localdomain>
References: <4222A8F2.6080004@candelatech.com>
	 <1109592365.2188.914.camel@jzny.localdomain>
	 <422353C9.6050001@candelatech.com>
	 <1109800554.1091.213.camel@jzny.localdomain>
	 <42263F6A.3020405@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42263F6A.3020405@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-02 at 17:34, Ben Greear wrote:
> jamal wrote:
> 
> > There are two ways to do this:
> > 
> > a) You could redirect to a packet socket - a small extension needed to
> > the redirect action (mostly mechanical details involved like keeping
> > state of which sockets are open etc).
> 
> I'd rather not take this approach, as I'd like to have this
> functionality available in a kernel module as well as user-space.  Netdevices
> are easy to work with in both user-space and kernel-space.

sure - you have modules and user space interface. But lets drop 
it here - I dont like it either because it may end up being a lot of
work.

> > tc filter add dev eth0 .... \
> > match ip src 10.0.0.1/32 \
> > action mirred egress redirect dev ring0
> > 
> > Assuming you have a program running on user space you should receive all
> > packets incoming and/or outgoing on eth0.
> > 
> > And no, you dont need the eth device to have a ip address attached.
> 
> Just mirror-ing will not meet my goal. 

The above was a total redirect, not mirroring; to mirror you would
say "action mirred egress mirror dev ring0"
And for fun you could mirror to multiple devices if you wanted.

>  I may also wish to drop packets
> entirely, before they ever reach any of the protocol stacks.

Of course thats what the actions are for. 

tc packets coming on dev XXXX before stack
 match some header ..
   action drop 

Or to add to the fun factor:

match some header ...
// randomly allow every 10th packet
action drop random netrand ok 10
// and redirect the lucky packet to user space
action mirred egress redirect dev ring0

> That said, a brief glance at the ntop page leads me to believe that
> his packet socket might be interesting for other reasons.  But, I have
> enough fun trying to push my own stuff into the kernel... probably
> won't bother trying to push his stuff in too :)
> 

Clearly above you are trying to reinvent whats already available.
And i pointed to that gent because i think hes done a good job already -
theres no point in reinventing what he already has in particular since
hes spent time to debug it and hes got people using it already (he seems
to be selling some product based on it). If he fails to cooperate then
by all means replicating his work should be fine.

cheers,
jamal
