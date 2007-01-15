From: "Mark Ryden" <markryde@gmail.com>
Subject: Two Dual Core processors and NICS (not handling interrupts on one CPU/assigning a Two Dual Core processors and NICS (not handling interrupts on one CPU / assigning a CPU to a NIC)
Date: Mon, 15 Jan 2007 11:15:52 +0200
Message-ID: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:51734 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932125AbXAOJPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 04:15:54 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2008269nfa
        for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 01:15:53 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,


I have a machine with 2 dual core CPUs. This machine runs Fedora Core 6.
I have two Intel e1000 GigaBit network cards on this machine; I use bonding so
that the machine assigns the same IP address to both NICs ;
It seems to me that bonding is configured OK, bacuse when running:
"cat /proc/net/bonding/bond0"
I get:

Ethernet Channel Bonding Driver: v3.0.3 (March 23, 2006)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth0
MII Status: up
Link Failure Count: 1
Permanent HW addr: .....

Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: ....

(And the Permanent HW addr is diffenet in these two entries).

I send a large amount of packets to this machine (more than 20,000 in
a second).

cat /proc/interrupts shops something like this:
				CPU0       CPU1         CPU2         CPU3
 50:    3359337          0          0          0         PCI-MSI  eth0
 58:         49    3396136          0          0         PCI-MSI  eth1

 CPU0 and CPU1 are of the first CPU as far as I understand ; so
 this means as far as I understand that the second CPU (which has CPU3
and CPU4) does not handle
 interrupts of the arrived packets; Can I somehow change it so the second
 CPU will also handle network interrupts of receiving packets on the nic ?

Can I assign one CPU to  eth0 and the second CPU to eth1  ?

Regards,
Mark
