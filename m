From: "Rick Koshi" <netdev@more-right-rudder.com>
Subject: Multiple GRE tunnels on the same host, only one routes incoming packets
Date: Sat, 11 Feb 2012 05:40:14 -0500
Message-ID: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm29-vm0.access.bullet.mail.sp2.yahoo.com ([98.139.44.192]:48408
	"HELO nm29-vm0.access.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750949Ab2BKKkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 05:40:17 -0500
Received: from hope.more-right-rudder.com (localhost.localdomain [127.0.0.1])
	by hope.more-right-rudder.com (8.14.5/8.14.4) with ESMTP id q1BAeESi014636
	for <netdev@vger.kernel.org>; Sat, 11 Feb 2012 05:40:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm having a routing problem on CentOS 6.2 (kernel 2.6.32-220)

Here's the setup:  One host is on my local network.  It's talking
to two nearly identical hosts at a remote location.  The two remote
hosts are on all the same networks, acting as redundant backups
for each other.

I set up two GRE tunnels from the local host, one to each
remote host:
    ip tunnel add name tunnel1 mode gre local 10.2.1.2 remote 10.2.1.1
    ip link set dev tunnel1 up
    ip route add 172.16.1.0/24 dev tunnel1 metric 101

    ip tunnel add name tunnel2 mode gre local 10.2.1.4 remote 10.2.1.3
    ip link set dev tunnel2 up
    ip route add 172.16.1.0/24 dev tunnel2 metric 102

Outgoing packets route properly, no problem.  Incoming packets
are weird.  It appears that whichever tunnel has the route
with the higher metric (tunnel2 in the example above) will
ignore incoming packets.  They come in all right, and can be
seen on the local machine with 'tcpdump -i tunnel2', but they
are not routed properly to the local networks.  They're simply
dropped.  I can switch the two metrics, and then tunnel1 will
drop all incoming packets.  The tunnel with the lower route
metric will route packets properly, both incoming and outgoing.

Is this "working as designed?"  What I'd like to have happen,
of course, is for all packets on both tunnels to be properly
forwarded.  Is this possible?

    -- Rick
