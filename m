From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 08 Jun 2004 07:28:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086694124.1039.44.camel@jzny.localdomain>
References: <200406062128.47070.vkondra@mail.ru>
	 <200406072335.04125.vkondra@mail.ru>
	 <1086651524.1037.10.camel@jzny.localdomain>
	 <200406080841.14579.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406080841.14579.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-08 at 01:41, Vladimir Kondratiev wrote:

> > DMA rings or channles on the NIC? Could you not use a tag like fwmark to
> > select DMA to send to?
> > Explain the packet path once it hits the driver.
>
> Let's put aside integrated service. For diff serv,
> NIC have 4 DMA queues. These 4 queues acts as 4 independent 802.11 channels 
> with different backoff and contention window parameters. Actually, it is 
> dictated by TGe, and should be common for wireless stack. Queue consumption 
> depends on conditions on air and access point settings. Access point set 
> these different parameters for queues, and may change it time to time.

Ok, Now that you explain this i dont think other people understood you
when you started talking about qos. We have discussed this topic on
netdev before under differnt context.

So the 4 DMA queues are infact different QoS levels? Another way to use
multiple tx DMA channels is to parallelize sending. Are there multiple
receive channels as well?
BTW, what is TGe?

The only obstacle i see at the moment in the architecture is we stop the
transmit path if a DMA ring is full. That is making assumption there is
only one DMA path. To work around this you could have 4 independent
virtual netdevices on top of the real physical device - something like a
tamed down bonding driver; this is not a very good abstraction because
there is only one physical MAC. 
Another scheme is to mark the fwmark or priority with the right DMA path
selection. Once it gets to the driver you try to send to the correct
ring and if thats full, you go to the next lower priority ring etc and
when theres no more DMA paths left you drop. The disadvantage with such
a scheme is complexity in keeping track of busy DMA paths.

I am trying to think of a clean way - maybe i need to get some caffeine
first. Jeff? Andi?

cheers,
jamal
