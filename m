From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Wed, 11 Jun 2003 11:48:19 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE6ECD3.6050103@tml.hut.fi>
References: <Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>	<20030609203659.089b241b.nakam@linux-ipv6.org>	<3EE5F85E.9080006@tml.hut.fi> <20030610.095135.28806569.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.095135.28806569.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller wrote:

> 
> If you want to do these things using routes or xfrm rules, you must
> integrate the creation of them into either zebra or racoon.  You
> cannot have a setup where mipv6d and racoon/zebra fight each other
> flushing each other's settings.  It doesn't work.
> 

In the routing based approach there should not be any conflicts between 
mipv6 and zebra: We would create cached host routes based on the 
existing routes. Thus if zebra was running, the mipv6 daemon would not 
change the routes created by zebra, but only cached host routes. If 
zebra changed any routes, it would cause the deletion of any invalid 
cached routes. The mipv6 daemon would listen to netlink messages for 
route deletion and would then reinsert the mipv6 state into a new cached 
route.

Does this make sense to you?

Thanks,

Henrik
