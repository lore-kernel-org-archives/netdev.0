From: santosh <ysan99@gmail.com>
Subject: How to indenfy the real physical network interface?
Date: Mon, 7 Nov 2011 19:29:19 +0530
Message-ID: <CAFcFeQJsnqPvgQs+hAvrUmEeMVaD4U1V2xbN68SMqxsjpdXvOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35743 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932220Ab1KGN7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 08:59:20 -0500
Received: by qao25 with SMTP id 25so604657qao.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 05:59:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am posting this question to "netdev" mailing list because I could
not find "linux-net" mailing list as suggested at
http://kernelnewbies.org/ML .

I have a wireless device running on Linux 2.6.15. (Can't upgrade to
latest at this time).

It has 3 interfaces.
 ath0 - Wireless interface.
 eth0 - Ethernet interface.
 br0 - Bridge interface joining ath0 and eth0.

I have a user space socket program that listens to the broadcast
messages and responds.
My socket is opened as sock = socket(PF_INET, SOCK_DGRAM, 0).

I need this socket program to listen for the packet coming from
Ethernet interface only.
Or, this socket program should be able to figure out the actual
interface the packet come from.

I tried below methods but both doesn't help me because kernel is
giving bridge as interface and not giving the real interface to socket
program.

1. //setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, "br0", 3)
 setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, "eth0", 4)

2. setsockopt(sock, SOL_IP, IP_PKTINFO, (char *) &on, sizeof on)
 // Use recvmsg instead of recvfrom and read the interface index.
 // If interface is not Ethernet do not respond.

Can you please let me know if there is a way to identify the actual
interface in a UDP socket program when traffic is being controlled by
a Bridge?


Thanks,
Santosh
