From: Ben Greear <greearb@candelatech.com>
Subject: Re: reserving skbuffs for the drivers
Date: Sun, 20 Oct 2002 22:00:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB389D5.9050403@candelatech.com>
References: <3DB31A32.9020107@candelatech.com> <20021021052031.B16412@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Sun, Oct 20, 2002 at 02:03:46PM -0700, Ben Greear wrote:
> 
>>I'm getting dropped rx packets because the network
>>driver cannot allocate an skbuf in time, evidently....
>>
>>I have 256MB of RAM, is there some way to increase the amount of RAM
>>that the kernel keeps around for GFP_ATOMIC allocations?
>>
>>Documentation I find talks about buffermem and freepages, which looks
>>hopeful, but they appear to no longer be in the proc file system as
>>tunables???
> 
> 
> You should be asking on linux-mm, not on netdev.
> 
> I've been complaining to the MM guys for years that they dropped freepages 
> in 2.4, which makes it impossible to tune the VM for heavy network load, but 
> so far nobody was interested in fixing it.
> 
> -Andi

Lord knows I don't mind complaining...didn't know a linux-mm list
existed...

I wonder though...since we use the skbuff malloc/free wrappers in the
networking code, maybe we could just keep a local cache of some
tunable size.  That may make the skb-malloc call as simple as popping
something off of a head of list for the majority of the cases, and should
free us from having to use the VM.  The kernel default could be quite small
so that low memory machines can still function w/out wasting memory...

The other thing is that my dropped packet problem was mostly fixed by
changing the rx buffer ring to be 512 instead of the 32 it was originally.
As Becker notes, this is not a real solution though...just a hack to make
the problem harder to trigger...

After I made that change, I noticed that most of my dropped packets happened
when the transmitter sent a packet, but the receiving NIC has no record of
receiving the packet (errors or otherwise).  I think there may be some bug
with running multiple ports at once (I never see the problem with 2 of the 4 ports
running, it's rare with 3, but with 4, it drops packets all over the place.)


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
