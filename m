From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Please explain this ARP behaviour.
Date: Wed, 26 Apr 2006 12:58:30 +0100
Message-ID: <444F6066.8020805@thekelleys.org.uk>
Reply-To: simon@thekelleys.org.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-cmbg4-0-0-cust914.cmbg.cable.ntl.com ([81.98.247.147]:28427
	"EHLO thekelleys.org.uk") by vger.kernel.org with ESMTP
	id S932405AbWDZL6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 07:58:31 -0400
Received: from guest491.wtgc.org ([193.62.205.238])
	by thekelleys.org.uk with asmtp (Exim 3.36 #1 (Debian))
	id 1FYif8-00005L-00
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 12:58:30 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two machines, many configuration differences, I need to find which one 
is causing this difference in behaviour:


Machine 1: (eth1 is on the correct 192.168.3.x network)

# ip neighbour add to 192.168.2.15 lladdr 00:0F:20:98:F8:86  nud \ 
reachable dev eth1

# cat /proc/net/arp
IP address       HW type     Flags       HW address            Mask 
Device
192.168.0.4      0x1         0x2         00:00:F8:04:9B:69     *   eth0
192.168.2.15     0x1         0x2         00:0F:20:98:F8:86     *   eth1
192.168.2.148    0x1         0x2         00:10:A4:F2:CF:CB     *   eth1

# ip neighbour show
192.168.0.4 dev eth0 lladdr 00:00:f8:04:9b:69 nud reachable
192.168.2.15 dev eth1 lladdr 00:0f:20:98:f8:86 nud reachable
192.168.2.148 dev eth1 lladdr 00:10:a4:f2:cf:cb nud stale

Note that hand-created entry appears in /proc and ip .. show


Machine 2: (similarly correct network)

# ip neighbour add to 192.62.204.15 lladdr 00:0F:20:98:F8:86\
      nud reachable dev eth1

IP address       HW type     Flags       HW address            Mask 
Device
193.62.204.1     0x1         0x2         00:0F:20:98:F8:87     *    eth1

# ip neighbour show
192.62.204.15 dev eth1 lladdr 00:0f:20:98:f8:86 nud reachable
193.62.204.1 dev eth1 lladdr 00:0f:20:98:f8:87 nud stale

Here, hand-created interface is in ip .. show, but missing from /proc

There is some reason to believe that the functional ARP behaves as 
/proc/net/arp (ie the hand-created entry is ignored) but I don't have 
absolute proof of that yet.

Machine 1 (works) is 2.6.12.2 hand compiled
Machine 2 (broken) is Ubunutu's 2.6.10-5-386, but this has possibly been 
seen in Debian 2.6.16.2 as well.

Please could someone suggest where I look next?


Cheers,

Simon.





