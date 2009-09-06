From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: [iproute2] tc action mirred    question
Date: Sun, 6 Sep 2009 10:13:40 -0700 (PDT)
Message-ID: <210469.98452.qm@web111611.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca
To: linux netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web111611.mail.gq1.yahoo.com ([67.195.23.98]:44950 "HELO
	web111611.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751955AbZIFR3k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Sep 2009 13:29:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have something to ask.

I construct a network like this:

/A\
B   D
\C/

All of the nodes(A, B, C, D) have two wireless cards (wlan0, wlan1).  A=
-B, B-C, A-D, D-C are wireless links.

Node A wnats to transmit packets with node C. Because the wireless link=
s are not very reliable, I want to forward the same packet through A-B-=
C and A-D-C simultaneously.=20
How to achieve my purpose=EF=BC=9F


Stephen Hemminger  said,
>Not sure what the best solution would be, but you could investigate
>using the 'tc filter mirred' action. Essentially, the traffic control
>command allows putting filters on output (or input) that can be used
>to do things like mirror packets.
>

On node A,
wlan0, IP address 192.168.1.1/24 ; wlan1, IP address 192.168.2.1/24
I use command 'tc filter add dev wlan0 ... match ip src 192.168.1.0/24 =
=2E..
action mirred egress mirror dev wlan1' to mirror packets.
When I use 'tcpdump -i wlan1', I can 'see' the packets  'A(wlan0)->B' (=
node B will forward them to C). How to forward the mirroring packets 'A=
(wlan1)' to D (then, node D forwards them to C) ?




Regards,
Wu



     =20
