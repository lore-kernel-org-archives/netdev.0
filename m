From: "Gabor Fekete" <kotrelmaller.borgenbach@gmail.com>
Subject: Handling of TAP interface packets by the kernel
Date: Thu, 10 Apr 2008 15:20:11 +0300
Message-ID: <690153640804100520o2b5c08c7j89a204f4e24636ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:50532 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbYDJMUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 08:20:12 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3020672wff.4
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 05:20:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have some weirdness with tap interfaces.

I have the following setup:
o one pc offline
o eth0 has ip 192.168.2.1/24 and 192.168.2.5/24
o tap0 has ip 192.168.2.1/32

I have a test C code. Which sends packets to 192.168.2.1 port 9090 like so:
#1 sends a forged IP datagram with raw socket to TCP port 9090 (IP_HDRINCL set).
#2 sends a UDP datagram to port 9090 with a regular UDP socket
#3 attempts connecting to port 9090 with a regular TCP socket
#4 sends a forged ETH datagram (same as in #1 but with an ETH header added) to
    TCP port 9090 via the tap0 interface by writing it to the tap file
descriptor. This tap0
    interface is created by this test code.

The source IP of the forged datagram is 192.168.2.5, source port is 49152,
the destination IP is 192.168.2.1 and destination port is 9090.
There is no socket in existence with source port 49152 on the machine.

I have no process listening on port 9090 at all on localhost.
When I run the test and capture "any" with wireshark I see:
#1 TCP RST sent back
#2 ICMP Dest unreach sent back (port unreach)
#3 TCP RST sent back
#4 nothing is sent back at all even thou I see the SYN arrive!

Any idea why don't I see the TCP RST in #4?

What I try to do is to have a TAP virtual interface and inject packets
to the kernel so that it would deliver it to either the localhost or forward it
to the internet. I though I could use TAP for this.
Also, I need the packets that are coming from tap0 and are forwarded
by the kernel
to also go through iptables.

Thanks,
Gabor
