From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC, PATCH] netlink based mq_notify(SIGEV_THREAD)
Date: 03 Apr 2004 17:01:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081029667.2037.55.camel@jzny.localdomain>
References: <406F13A1.4030201@colorfullife.com>
	 <1081023487.2037.19.camel@jzny.localdomain>
	 <406F21FB.4010502@colorfullife.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        Michal Wronski <wrona@mat.uni.torun.pl>,
        Krzysztof Benedyczak <golbi@mat.uni.torun.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <406F21FB.4010502@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-04-03 at 15:43, Manfred Spraul wrote:

> Thus the kernel interface for mq_notify with sigev_notify==SIGEV_THREAD 
> is an asynchroneous interface: the initial syscall just registers 
> something and if a message arrives in the queue, then a notice is sent 
> to user space. glibc must then create a SuS compatible interface on top 
> of that.

The above is a good description of the challenge i think.

[..]

> I'm looking for the simplest interface to send 32 byte cookies from 
> kernel to user space. The final send must be non-blocking, setup can 
> block. Someone recommended that I should look at netlink. 
> netlink_unicast was nearly perfect, except that I had to split setup and 
> sending into two functions.

Your split of netlink_unicast seems fine ; 
I guess the bigger question is whether this interface could be a
speacilized netlink protocol instead? It doesnt seem too nasty as is
right now, just tending towards cleanliness.
It seems that user space must first open a netlink socket for this to
work but somehow the result skb is passed back to userspace using the
mq_notify and not via the socket interface opened? Why should user space
even bother doing this? The kernel could on its behalf, no? Are you sure
there will always be one and only one message outstanding always?

cheers,
jamal
