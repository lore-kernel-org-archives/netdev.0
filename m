From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from	unjoined
 groups
Date: Fri, 11 Jul 2008 11:43:28 -0700
Message-ID: <OF46B757A0.16C39B0B-ON88257483.00656D0F-88257483.0066D899@us.ibm.com>
References: <20080711173549.GC4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49763 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542AbYGKSnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 14:43:46 -0400
In-Reply-To: <20080711173549.GC4534@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 07/11/2008 10:35:49 AM:

> So you're saying that if I take a process, call bind, specifying 
INADDR_ANY, and
> then call setsockopt(...,IP_ADD_MEMBERSHIP,...) specifying a multicast 
group X,
> that I can expect to recieve messages from other multicast addresses 
that other
> processes in the system have joined to? 

Yes.

> That doesn't seem at all correct, and
> it contradicts what you and I discussed privately. 

        I don't remember discussing this with you privately, but I think
either I wasn't clear, or there's a misunderstanding. I think it doesn't
seem correct to you because you have a different model in mind. You're 
thinking
(as almost everyone seems to) that the join has something to do with the 
socket.
The model, from the original implementation, is the same as for unicast
addresses-- it is adding an address _to_the_machine_. It isn't a private
address for that socket only.
        The binding is what determines delivery to the socket. If you have
other traffic on the same port that you don't want, then you don't want
INADDR_ANY.

> As the code currently
> stands, if you do the above in process A, joining mcast group X, and 
then start
> a second process on the same system, joining mcast group Y, process A 
will
> recieve mcast group Y frames.

        Yes. In fact, there are programs that rely on this. Some versions
of JVM join all the groups it needs in one process, but other processes
do all the I/O for those groups.

That's how it has always worked in the original socket implementation 
(BSD)
and derivatives. The control for socket reception is the binding, so if 
you
want only mcast X packets, you need to bind to X. If you bind to 
INADDR_ANY,
that *means* you don't care what the destination address is and you'll 
receive
all unicast and multicast packets with a matching port and protocol.

                                                                +-DLS

