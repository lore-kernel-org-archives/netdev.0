From: "George B." <georgeb@gmail.com>
Subject: Possible sequence number corruption? 2.6.32-24
Date: Thu, 16 Dec 2010 23:20:43 -0800
Message-ID: <AANLkTimxdEugiN9UM=9WdMJeL+1=2epruYOG9=6SjmO=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55755 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab0LQHUo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 02:20:44 -0500
Received: by iwn9 with SMTP id 9so424478iwn.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 23:20:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a box running an Ubuntu kernel (2.6.32-24-server #43-Ubuntu SMP)

It has 4 IP addresses on a bond interface.=A0 We noticed today a strang=
e
problem with a load balancer attempting to connect to one of the
addresses.=A0 We would see a syn from the balancer, the syn-ack goes
back from the Linux box and then an immediate reset from the balancer
(Citrix Netscaler running 8.1).

After taking a packet capture on both machines I see this:

Netscaler sends (or thinks it sends)


Transmission Control Protocol, Src Port: 33860 (33860), Dst Port: 7080
(7080), Seq: 4246152065, Len: 0

Linux box sees this:

Transmission Control Protocol, Src Port: 33860 (33860), Dst Port: 7080
(7080), Seq: 1098970366, Len: 0

Note the sequence number has changed.  This is a flat layer2 network
between them.

Linux replies with:

Transmission Control Protocol, Src Port: 7080 (7080), Dst Port: 33860
(33860), Seq: 1187929616, Ack: 1098970367, Len: 0

And the Netscaler, seeing the out of whack sequence number sends a RST.

Now if I connect to that same IP/Port from another Linux box, it works
fine.  If I connect from the load balancer to a different IP on the
same box it works fine.  If I connect from a different load balancer
to the troublesome IP/port, I get the same result.  It seems unlikely
that two different load balancers would be scrambled in exactly the
same fashion and only to one IP on the box.  In fact, there are two
different servers exhibiting the same problem when either of the load
balancers attempts to connect and it works great to other IP addresses
on those same two servers.  We have not experienced this problem with
these load balancers or kernel version on Linux before but it could be
some "magic" combination of numbers or something, I have seen stranger
things.

The linux interface is a bond interface in balance-xor mode with the
default transmit hash..  The NICs are bnx2 driver v2.0.2

I am not physically at the network so I can not mirror a port and see
what exactly is on the wire but I have taken packet captures using
tcpdump on the machines at both ends that I can provide if desired.
Has anyone else seen or heard of any odd sequence number corruption in
a similar configuration?

Thanks,

George
