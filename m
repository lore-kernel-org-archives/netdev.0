From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: anyone ever done multicast AF_UNIX sockets?
Date: Thu, 27 Feb 2003 15:09:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E5E7081.6020704@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It is fairly common to want to distribute information between a single 
sender and multiple receivers on a single box.

Multicast IP sockets are one possibility, but then you have additional 
overhead in the IP stack.

Unix sockets are more efficient and give notification if the listener is 
not present, but the problem then becomes that you must do one syscall 
for each listener.

So, here's my main point--has anyone ever considered the concept of 
multicast AF_UNIX sockets?

The main features would be:
--ability to associate/disassociate a socket with a multicast address
--ability to associate/disassociate with all multicast addresses 
(possibly through some kind of raw socket thing, or maybe a simple 
wildcard multicast address)
--on process death all sockets owned by that process are disassociated 
from any multicast addresses that they were associated with
--on sending a packet to a multicast address and there are no sockets 
associated with it, return -1 with errno=ECONNREFUSED

The association/disassociation could be done using the setsockopt() 
calls the same as with udp sockets, everything else would be the same 
from a userspace perspective.

Any thoughts?  How hard would this be to put in?

Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
