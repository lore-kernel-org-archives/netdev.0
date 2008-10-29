From: Michael Tokarev <mjt@tls.msk.ru>
Subject: linux bridge and MTU
Date: Wed, 29 Oct 2008 16:24:51 +0300
Message-ID: <49086423.9050104@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:21271 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753633AbYJ2NYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 09:24:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's an interesting interaction between different
MTU (max transmission unit) values on interfaces
which are bridged together.  I'm trying to understand
how it works.

Suppose there are 2 interfaces in the bridge, one is
with standard 1500 mtu and another is, say 3500.

As far as I can see, bridge interface sets its mtu to
be the smallest of all the components.  Which seems
to be the right ting to do.

But now the question is - is it possible to communicate
over the interface with larger MTU using full frames?

For example, here are a tcpdump from a single ping-pong
"pair" between host "B" which is connected to a larger-MTU
interface, and host "A" which is with the bridge described
above, using 3000-byte packets:

IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 3028) B > A ICMP echo request, id 35331, seq 2, length 3008

IP (tos 0x0, ttl 64, id 39747, offset 0, flags [+], proto ICMP (1), length 1500) B > A: ICMP echo reply, id 35331, seq 2, length 1480
IP (tos 0x0, ttl 64, id 39747, offset 1480, flags [+], proto ICMP (1), length 1500) B > A: icmp
IP (tos 0x0, ttl 64, id 39747, offset 2960, flags [none], proto ICMP (1), length 68) B > A: icmp

So, the reply comes in 3 packets according to 1500 MTU of
the bridge interface.

When forwarding from B to some host C connected to the other
interface with standard 1500 mtu, host A correctly sends
"fragmentation required" ICMP back, so that part works.
Also, host A obviously is able to receive larger frames.
But it can't SEND larger frames, even if the underlying
interface has proper MTU settings?

Is there a way to achieve this?

Thanks!

/mjt
