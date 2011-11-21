From: Albert Chin <linux-netdev@mlists.thewrittenword.com>
Subject: Problems with dropped packets on bonded interface for 3.x kernels
Date: Sun, 20 Nov 2011 23:16:04 -0600
Message-ID: <20111121051603.GB3702@china>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.thewrittenword.com ([69.67.212.77]:52631 "EHLO
	mail1.thewrittenword.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428Ab1KUFZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:25:21 -0500
Received: from mail1.il.thewrittenword.com (emma-internal-gw.il.thewrittenword.com [192.168.13.25])
	by mail1.thewrittenword.com (Postfix) with ESMTP id DA6095C17
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 05:51:07 +0000 (UTC)
Received: from china.thewrittenword.com (danger-gw.il.thewrittenword.com [10.191.57.254])
	by mail1.il.thewrittenword.com (Postfix) with ESMTP id 477716F5
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 05:16:05 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running Ubuntu 11.10 on an Intel SR2625URLXR system with an Intel
S5520UR motherboard and an internal Intel E1G44HT (I340-T4) Quad Port
Server Adapter. I am seeing dropped packets on a bonded interface,
comprised of two GigE ports on the Intel E1G44HT Quad Port Server
Adapter. The following kernels exhibit this problem:
  3.0.0-12-server, 3.0.0-13-server, 3.1.0-2-server, 3.2.0-rc2
Installing Fedora 16 with a 3.1.1-1.fc16.x86_64 also showed dropped
packets.

I also tried RHEL6 with a 2.6.32-131.17.1.el6.x86_64 kernel and didn't
see any dropped packets. Testing an older 2.6.32-28.55-generic Ubuntu
kernel also didn't show any dropped packets.

So, with 2.6, I don't see dropped packets, but everything including
3.0 and after show dropped packets.

# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:1b:21:d3:f6:0a  
          inet6 addr: fe80::21b:21ff:fed3:f60a/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:225 errors:0 dropped:186 overruns:0 frame:0
          TX packets:231 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:25450 (25.4 KB)  TX bytes:28368 (28.3 KB)

With lacp_rate=fast, I see higher packet loss than with
lacp_rate=slow. I've tried bonding t

This server has the following network controllers for the two internal
NICs:
  # lspci -vv
  01:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit Network Connection (rev 02)
  01:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Network Connection (rev 02)

And it has the following network controllers for the four NICs on the
I340-T4 PCI-E card:
  # lspci -vv
  0a:00.0 Ethernet controller: Intel Corporation 82580 Gigabit Network Connection (rev 01)
  0a:00.1 Ethernet controller: Intel Corporation 82580 Gigabit Network Connection (rev 01)
  0a:00.2 Ethernet controller: Intel Corporation 82580 Gigabit Network Connection (rev 01)
  0a:00.3 Ethernet controller: Intel Corporation 82580 Gigabit Network Connection (rev 01)

I tried bonding the two 82575EB NICs rather than two NICs on the 82580
but see the same dropped packet issue.

I have replaced the cables, tested each port individually on the
switch without bonding, and don't see any reason to expect hardware as
the issue. The switch is a Summit Extreme 400-48t.

I am using a 802.3ad configuration:
# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 200
Down Delay (ms): 0

802.3ad info
LACP rate: fast
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
        Aggregator ID: 1
        Number of ports: 1
        Actor Key: 17
        Partner Key: 24
        Partner Mac Address: 00:04:96:18:54:d5

Slave Interface: eth4
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:1b:21:d3:f6:0a
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth5
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:1b:21:d3:f6:0b
Aggregator ID: 2
Slave queue ID: 0

Anyone have any ideas?

-- 
albert chin (china@thewrittenword.com)
