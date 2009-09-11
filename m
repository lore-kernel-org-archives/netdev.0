From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
	numbers
Date: Fri, 11 Sep 2009 17:21:42 -0400
Message-ID: <1252704102.25158.36.camel@dogo.mojatatu.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org,
	balbir@in.ibm.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2009-09-11 at 15:33 -0400, Eric Paris wrote:


> 
> I'm willing to try to make this happen, I'm just sure I see the benefit
> and I don't know anyone who knows the net/netlink code well enough who
> owuld be interested to help.....
> 

I can help you on the netlink side but maybe we need to define the
problem scope properly first. I dont know anything about fanotify, but
i then dont need to. Can I re-phrase your problem as follows:

You have kernel code which wishes to communicate information to multiple
listeners in user space. The listeners register some form of filter
(that you term as a monitor) for an object of interest.  For a specific
filter you wish to send them events when something happens to
the object they registered for.
Would the above be accurate?

One good place to start is the taskstats code in linux. Look at
Documentation/accounting in the kernel code. Ive also CCed Balbir who
was involved in that work since i think it bears similarity to what you
are trying to achieve conceptually.

To your other statements:
0) A single skb can be used to send to all the listners..
1) Netlink messages wont get lost unless the listener is not keeping up
and the kernel sending it messages ends up filling its queues. In such a
case your event message will be delivered to the 49 other users but
not the overloaded one. You can add sequence numbers to the event
messages you send to the listeners and any gaps in sequences on received
events imply lost events. You can add a mechanism to query your user
space kernel when something like that gets lost.
2) Your architecture has to take care of maintaining the state of what
you want to deliver. So your editing has nothing to do with skbs.
i.e an event happens, you update your state. If you need to send the
event to the listeners, you alloc an skb - populate it with the info;
multicast it to all the listeners. If something else happens, i would
suggest for sake of simplicity you rinse and repeat. Sure, the listener
may get contradicting events - but they should be able to handle it.

I hope this helps...

cheers,
jamal



