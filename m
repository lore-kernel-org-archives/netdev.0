From: Prashant Upadhyaya <praupadhyaya@gmail.com>
Subject: Problem with fragmented packets on tun/tap interface
Date: Fri, 31 Jul 2015 12:30:31 +0530
Message-ID: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33521 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbGaHAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 03:00:33 -0400
Received: by lbbyj8 with SMTP id yj8so40671476lbb.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 00:00:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am having a linux user space application which gets data from an
interface (eg. eth0) using a packet socket. The application has a fast
path and a slow path. In the fast path the packets are processed by
the application and sent out via the packet socket. Certain packets
need processing by linux IP stack -- this constitutes the slow path. I
use a tun/tap interface to inject the packet into the kernel in case
it deserves slow path processing. When the kernel responds, I read the
packets back from the tap and send it out via the packet socket. I use
iptable rules to drop the packets at the entry from the interface so
that they are not processed by kernel directly (because I read them
via packet socket and then inject into the kernel via the tap
interface)
iptables -A INPUT -i eth0 -j DROP
iptables -A FORWARD -i eth0 -j DROP


Now the above mechanism works very well for me except when the slow
path encounters fragmented IP packets. When I inject the fragmented IP
packets into the kernel via the tap interface, the kernel does
not.respond (eg. for a ping bigger than mtu size) I have checked with
tcpdump on tap that I have injected all the fragments into the kernel.

Strangely enough, the same usecase works if I put the delays (usleep)
at two places in my application --

1. Just before writing the packet to tap  (injection into the kernel)
2. Just after reading the kernel response from the tap and just before
sending the packet out using the packet socket.

The delays work for me but is clearly not good for the performance of
the slow path. And more importantly, I was looking for a fundamental
reason regarding why it works with delays and why not without it. The
issue is reproducible with a big ping (3.11.10-301.fc20.x86_64)

Regards
-Prashant
