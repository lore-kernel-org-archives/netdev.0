From: Greg Daley <greg.daley@eng.monash.edu.au>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Fri, 28 Feb 2003 09:21:38 +1100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E5E8F72.2080206@eng.monash.edu.au>
References: <3E5E7081.6020704@nortelnetworks.com>
Reply-To: greg.daley@eng.monash.edu.au
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Chris Friesen <cfriesen@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

Hi Chris,

Please check out the uml_switch
written by jeff dike for Mser Mode Linux.

It is a user-space program which emultates
an ethernet switch (or hub).  It emulates
link-layer multicast on UNIX domain sockets.

Greg Daley

Chris Friesen wrote:
> 
> It is fairly common to want to distribute information between a single 
> sender and multiple receivers on a single box.
> 
> Multicast IP sockets are one possibility, but then you have additional 
> overhead in the IP stack.
> 
> Unix sockets are more efficient and give notification if the listener is 
> not present, but the problem then becomes that you must do one syscall 
> for each listener.
> 
> So, here's my main point--has anyone ever considered the concept of 
> multicast AF_UNIX sockets?
> 
> The main features would be:
> --ability to associate/disassociate a socket with a multicast address
> --ability to associate/disassociate with all multicast addresses 
> (possibly through some kind of raw socket thing, or maybe a simple 
> wildcard multicast address)
> --on process death all sockets owned by that process are disassociated 
> from any multicast addresses that they were associated with
> --on sending a packet to a multicast address and there are no sockets 
> associated with it, return -1 with errno=ECONNREFUSED
> 
> The association/disassociation could be done using the setsockopt() 
> calls the same as with udp sockets, everything else would be the same 
> from a userspace perspective.
> 
> Any thoughts?  How hard would this be to put in?
> 
> Chris
> 
> 


