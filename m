From: Sumedha Gupta <2sumedha@gmail.com>
Subject: Bandwidth of NIC bonding/trunking
Date: Fri, 31 Jul 2009 09:40:51 -0400
Message-ID: <869c36e20907310640m41163a2j57198d8ea5e91ba0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:26523 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbZGaNkv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 09:40:51 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1109535qwh.37
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 06:40:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I configured bonding/trunking on a Netgear GS724TR switch. I am using
a 4-port NIC card using=A0Intel Corporation 82571EB ethernet controller
on machine X with all four ports connected to the switch. There are
four client machines (A, B, C, D) also connected to the switch.
iperf is running on machine X as a server and machines A, B, C, D are
running as iperf clients:
With round robin, I consistently get:
=A0Interval =A0 =A0 =A0 =A0 =A0 =A0Transfer =A0 =A0 =A0 =A0 Bandwidth
=A00.0-10.0 sec =A0 =A0992 MBytes =A0 =A0831 Mbits/sec
=A00.0-10.0 sec =A0 =A0989 MBytes =A0 =A0828 Mbits/sec
=A00.0-10.0 sec =A01019 MBytes =A0 =A0854 Mbits/sec
=A00.0-10.0 sec =A0 =A0965 MBytes =A0 =A0808 Mbits/sec
However with XOR, I am not getting enough bandwidth:
=A00.0-10.0 sec =A0 =A0619 MBytes =A0 =A0519 Mbits/sec
=A00.0-10.0 sec =A0 =A0398 MBytes =A0 =A0333 Mbits/sec
=A00.0-10.0 sec =A0 =A0338 MBytes =A0 =A0283 Mbits/sec
=A00.0-10.0 sec =A0 =A0612 MBytes =A0 =A0513 Mbits/sec
Similar results with transmit load balancing (tlb), 802.3ad, active
backup and broadcast:
=A00.0-10.5 sec =A0 =A0421 MBytes =A0 =A0336 Mbits/sec
=A00.0-10.1 sec =A0 =A0323 MBytes =A0 =A0269 Mbits/sec
=A00.0-10.0 sec =A0 =A0301 MBytes =A0 =A0252 Mbits/sec
=A00.0-10.0 sec =A0 =A0405 MBytes =A0 =A0339 Mbits/sec
Although, with adaptive load balancing I was constantly getting
perfect bandwidth:
=A00.0-10.0 sec =A01.09 GBytes =A0 =A0937 Mbits/sec
=A00.0-10.0 sec =A01.09 GBytes =A0 =A0937 Mbits/sec
=A00.0-10.0 sec =A01.09 GBytes =A0 =A0937 Mbits/sec
=A00.0-10.0 sec =A01.09 GBytes =A0 =A0937 Mbits/sec
I wanted to know if so much change with mode change in bonding is
expected or did I configure something wrong in the switch which is
causing xor, tlb, 802.3ad etc. to not work properly?

Thanks,
Sumedha
