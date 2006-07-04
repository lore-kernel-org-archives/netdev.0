From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 4 Jul 2006 22:47:11 +0200
Message-ID: <200607042247.12296.ak@suse.de>
References: <adawtazgawi.fsf@cisco.com> <200607011626.04539.ak@suse.de> <1152038079.3285.586.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:61872 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932399AbWGDUpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 16:45:02 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1152038079.3285.586.camel@tahini.andynet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> So perhaps there's a good argument to make that a Linux system with the
> right hardware could be considered a core device. Likely any place you
> have such a system it would be dedicated to just moving data as well as
> possible, and let other systems do the other stuff. You wouldn't want
> your server farm systems to also be your firewalls.

Why not? While Linux firewall performance is not flawless its problems
(e.g. slow conntrack) seems to be mostly in an area where TOE cannot
do much about.

> Bottom line - these technologies seem to me to have a place in a well
> designed network.

I think there is a web page listing why it's bad, but here 
a quick summary:

One worry is to debug it all together. Currently we have a single stack
to debug, although it's already difficult to control the complexity as it 
grows more bells and whistles.

Just take a look at Cisco IOS release notes to see how hard
and difficult it is to get it all to work together.

Another reason is that there are general doubts that TOE can
keep up with the ever growing performance of CPUs. Even if Linux
added it today it would be likely slower again a few months later.
That is also a big difference to Cisco hardware. Linux usually
runs on fast main CPUs (or if you run it on slow CPUs you normally
don't expect the best network performance). And they get faster
and faster constantly.

Admittedly 10GB NICs are still a bit too fast for
mainstream systems, but that seems to be mostly a problem
outside the CPUs and it looks like the next generation
of systems will catch up with enough bandwidth in this area.

Also it tends to accelerate the wrong thing. On a lot of workloads
the main problem is keeping a lot of different connections under 
control, and TOE tends to be slow at keeping connection
information synchronized with the host.

That is why the Linux strategy has been to ask for useful stateless offloads
instead. Examples of this are checksum offload (long time classic), TSO (TCP 
segmentation offload), UFO (UDP segmentation offload), Intel iOAT (memcpy off 
load), RX hashing with MSI-X (not implemented yet, but basically
it allows load balancing of incoming streams to CPU) 

Note that all these are more or less stateless offloads.

iWARP is not clear yet what it is. From the meager bits of information
about it that reached netdev so far it at least sounds it does RDMA and needs 
far more state than any of the other offloads we got so far and likely
got the usual TOE scaling issues. It's also likely on the wrong side 
of Moore's law.

-Andi
