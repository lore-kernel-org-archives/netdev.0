From: Nivedita Singhvi <niv@us.ibm.com>
Subject: OSDL Bugzilla #2399: A user can remotely route a packet through eth0
 on a Linux machine
Date: Tue, 11 May 2004 11:07:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A11644.7090402@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: snortwiz@hotmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forwarding a bug report from Jared McLaren below.
Any thoughts?

thanks,
Nivedita


I couldn't Google up any information on this situation, so here goes...

Distribution:
Mandrake

Hardware Environment:
Gateway 450SX4 laptop

Software Environment:
Mandrake 10, kernel 2.6.3-4mdk

Problem Description:
While pen-testing a dual-homed Linux-based VPN appliance, I discovered the
device would route packets between its two interfaces without ip forwarding
enabled.  I could route packets directly to the external interface by setting
the internal interface as the gateway.  This device is based on a 2.4 kernel.  I
tested this on my Mandrake 10 (2.6.3-4mdk) laptop and found the same results
from the 2.6.x kernel.

For a test, I placed my wireless network card (eth1) in my laptop and assigned
it the IP address 10.10.255.254.  I bound SSH to 10.10.255.254 and restarted
SSH.  My wired ethernet card (eth0) was at IP address 172.20.13.162.  On a
remote desktop, I confirmed SSH was not available on 172.20.13.162.  On that
remote desktop I then added a route to 10.10.255.254 using gateway 172.20.13.162
and could then SSH to 10.10.255.254.  A 'cat' or /proc/sys/net/ipv4/ip_forward
on the Linux laptop was "0" so ip forwarding was not enabled.

The end result is that you can reach services bound to an interface on a Linux
machine that you may not be able to normally reach.  This was all performed in
the default kernel configuration.  This is only possible when one of the
interfaces resides on your network segment since it is used as a gateway.

Steps to reproduce:
	a) Use a dual-homed machine (eth0, eth1)
	b) bind a service to eth1
	c) from a different machine, add a route to the IP of eth0
	d) attach to the service on the IP of eth1
