From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: Deleting incoming network packets / sk_buff
Date: Sun, 15 Aug 2004 20:05:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411FA5D0.6000004@web.de>
References: <411E642C.9010708@web.de> <411E8EE4.70900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <411E8EE4.70900@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Ben.

First of all, thanks for your answer.

Ben Greear wrote:
> There is no way that I am aware of to block packets from high-level 
> protocols, but you can disable the higher protocols (ie, set IP to 
 > 0.0.0.0).

Unfortunately this doesn't work for my setup. I have some kind of 
userspace bridge implementation running, which copies frames incoming on 
a physical device (e.g. eth1) to a virtual (tun/tap) device (e.g. tap0) 
and vice versa. When the kernel wants to communicate with the outside 
world it does this by using tap0, and the program "bridges" the packets 
to eth1. In order to avoid to have eth1 running in promiscious mode I 
configure tap0 to have the same MAC address as eth1 - but this has the 
drawback that the kernel sees every incoming packet twice: once when it 
hits eth1, and once when it gets copied by the userspace bridge to tap0.

There is no simple way to have the incoming communication "split" over 
both interfaces without running in serious troubles regarding firewall 
rules or such things as having quagga/zebra dropping incoming OSPF 
announces from eth1 (since it self uses tap0 to communicate with the 
outside world).

Abd yes, it is necessary to have this host only using tap0 for outgoing 
communication (it would be longish to explain the reason, just believe 
me for now ;)).


Bottom line: the easiest way to solve this problem would be to have some 
way for blocking packets on eth1 from being processed (after they have 
been passed to the packet socket - else my userspace program won't be 
able to "bridge" incoming packets to tap0).

> You can also hack net/core/dev.c to stop the packets from going
> up the stack, but it requires more than just a new kernel module,
> you'd have to actually change dev.c.  (Search for BRIDGE).

Hmm, now that you mention it: at least the 2.4.x kernels I use have the 
bridging code enabled. I'll take a look at possible hooks or other 
mechanisms that are used by the bridging code for its job - maybe this 
will help. Thanks for the hint.

Bye, Mike
