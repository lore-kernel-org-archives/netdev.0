From: Tupshin Harper <tupshin@tupshin.com>
Subject: FW: gigabit ethernet, nfsroot, jumbo packets, questions, and bugs
 (2.6.0-test9)
Date: Fri, 14 Nov 2003 13:20:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB54707.5030102@tupshin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forwarded from lkml by request:

I'm trying to set up a diskless testbed using gigabit ethernet, and I'm 
running into a few issues. First, the scenario:

One client, and one server each with an smc EZCard 1000.
Kernel 2.6.0-test9 with the sk98lin driver on both sides
Client has kernel compiled with sk98lin built in, and nfsroot and dhcp 
autoconfig built in.
Client is getting bootstrapped off a hard drive (for now, since 
etherboot doesn't support the driver yet) with grub loading the nfsroot 
kernel from disk, and then mounting nfsroot by adding root=/dev/nfs


What works:
Everything basic.

What doesn't:
Above scenario with Jumbo packets (MTU = 9000 or anything above 1500)

For performance reasons, I'm wanting to use large packets(the switch 
between the devices supports it, and jumbo packet communication works 
fine in the non-diskless scenario).

Questions:
1) Is there a good way to set the MTU of the client via dhcp or by 
passing a parameter to the kernel?

2) If server is set to 9000 MTU and client is set to 1500 MTU, should 
complete failure ensue(e.g. nfs times out indefinitely), or should some 
autonegotiation take place? If there should be autonegotiation, then it 
isn't working.

Definite Bug:
If the server is set to 9000 MTU, ifconfig down, and ifconfig up with 
default MTU doesn't work. Ifconfig then claims that the card is set to 
1500 MTU, but it is unable to communicate with the client until module 
is unloaded and reloaded, even though MTU is an ifconfig parameter and 
not a module parameter. I'm presuming that MTU has not actually been set 
back to 1500, but I don't know of an easy way to tell if that's the case 
when ifconfig appears to be lying to me.

-Thanks
-Tupshin
