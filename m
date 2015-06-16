From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: slow TCP speed through linux ip forwarding
Date: Tue, 16 Jun 2015 12:35:06 +0200
Message-ID: <557FFBDA.9040501@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:57923 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbbFPKfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

i hope somebody has an idea for my problem and may point me to the right
direction. Alle servers run kernel 3.18.14.

My problem is that i can't archieve more than 20Mbit/s using a single
TCP stream and i've no further ideas how to solve it.

reduced Network Map

Server A
  |
Linux GW Server
  |
Brocade Router  - Server B
  |
Internet
  |
Server C

The Linux GW Server does nothing more than being an ip forwarding GW.
(no iptables / packet filtering).

I've done the following Tests while the Linux GW has a traffic of around
500-600Mbit/s:

Download file from Server A to C: 10-20Mbit/s
Download file from Server A to B: 100Mbit/s
Download file from Server B to C: 100Mbit/s

4 parallel downloads from Server A to C: 80-100Mbit/s

Same test with no other traffic on the Linux GW:

Download file from Server A to C: 100Mbit/s
Download file from Server A to B: 100Mbit/s
Download file from Server B to C: 100Mbit/s

4 parallel downloads from Server A to C: 100Mbit/s

Same test with net.ipv4.tcp_congestion_control=bic on Server A:

Download file from Server A to C: 70Mbit/s
Download file from Server A to B: 100Mbit/s
Download file from Server B to C: 100Mbit/s

4 parallel downloads from Server A to C: 80-100Mbit/s

ehtootl -S shows no errors for eth0 and eth1 on the linux gw.

I've no further ideas.

Thanks a lot.

Greets,
Stefan
