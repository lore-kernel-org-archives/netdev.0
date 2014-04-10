From: David Newall <davidn@davidnewall.com>
Subject: No return for ping -R; not sure if this is the right list
Date: Thu, 10 Apr 2014 16:29:52 +0930
Message-ID: <53464168.90508@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:49325 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934241AbaDJHE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 03:04:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

I apologise if this is the wrong list.  It's a user question, not a 
development question, which I wanted to send to the linux-net list, but 
that list no longer exists (according to vger.kernel.org.)  I couldn't 
find where it went, and I'm hoping, if this is not the right place, that 
someone will kindly point me in the proper direction.

My problem is a large number of duplicate ACKs, retransmitted packets, 
and packets out of order.

I'm running Ubuntu 13.10 on a Dell 1920, with Ubuntu's twist of Linux 
3.11.0-18-generic kernel.  I have two ethernet ports bonded in 
active-backup mode, and bridged with STP on.  I've got a number of 
virtual hosts running on it, using kvm (QEMU 1.5.0, QEMU API 1.1.1) and 
libvirt (1.1.1).

Some type of Cisco router sits in front of the machine, which is managed 
by the DC who hosts my server.  They also advertise my public IP range 
with BGP.  Apparently there are two independent routes.

I wanted to confirm that the problem is not routing, and thought a 
number of pings with record-route might help, but get no packets 
returned other than when I ping one of the server's own IP addresses.  
Even when I ping a virtual host with -R, no pings are returned, at least 
according to ping, although I do see them using tcpdump.

They appear to be discarded somewhere on the server, but I cannot find 
where.

It's possible the DC is dropping packets with RR option set, and have 
sent them email asking this to be confirmed and changed, but that does 
not explain why a ping -R to a virtual host doesn't work.

Inserting --proto icmp -j ACCEPT rules in the INPUT, FORWARD & OUTPUT 
chains of the server's iptables' filter table does not help. According 
to /proc/net/ip_tables_names, the only other table is mangle, for which 
all chains are ACCEPT policy and empty, other than POSTROUTING which is 
ACCEPT policy and has CHECKSUM fill rules covering UDP port 68 to two of 
my virtual sub-nets.

There are no iptables rules at all on the target virtual-host.

Even though I'm sure you all already picked up this, just to clear, I am 
not using the iptables ipv4options module, nor, that I can see, any 
other iptables-based rule that would do this.

So, any suggestions to explain what is dropping these pings, or what is 
causing the duplicate acks, retransmits and out-of-order packets, would 
be very gratefully received.  Or, even just a pointer to a better place 
to ask.

David
