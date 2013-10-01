From: Wolfgang Walter <linux@stwm.de>
Subject: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Tue, 01 Oct 2013 18:39:32 +0200
Message-ID: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:46053 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751508Ab3JAQrn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 12:47:43 -0400
Received: from mailhub.studentenwerk.mhn.de (mail.studentenwerk.mhn.de [10.148.7.34])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 551CA58004
	for <netdev@vger.kernel.org>; Tue,  1 Oct 2013 18:39:33 +0200 (CEST)
Received: from h2o.as.studentenwerk.mhn.de (h2o.as.studentenwerk.mhn.de [10.148.0.199])
	by mailhub.studentenwerk.mhn.de (Postfix) with ESMTP id 51C29100084
	for <netdev@vger.kernel.org>; Tue,  1 Oct 2013 18:39:33 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I tried to upgrade one of our routers to 3.10.13 from 3.4.63 and I see =
a=20
dramatic performance loss. I tried 3.11.2 and it is still there.

*** Symptoms:

All network traffic over the router become slow and sluggish. If one pi=
ngs the=20
router there is a packet loss. After about 2 minutes the traffic comple=
tely=20
stalls for about 1 minute. Then it works again as in the beginning to t=
hen=20
stall again. And so on.

This happens even with rather moderate traffic. While still routing the=
 CPU=20
utilization is higher than it is with 3.4.63 but only moderately.

When it stalls no network traffic seems possible (but to loopback). If =
one=20
tries to ping from the router any target (even if it is on a interface =
with no=20
traffic at all) one gets:

	ping: sendmsg: No buffer space available

As the router has about 15G free memory this probably means that an int=
ernal=20
table is full.

The CPU-utilization is low within that period.


I can trigger it easily when I copy about 50 big files per scp over 50=20
different ipsec-tunnels:

* boot router

* wait until all ipsec tunnels are established

* start copying:

H <--1G--> Router <---1G--->.......<-- >=3D100MBit --> Xn <---100Mbit--=
--> Rn

So there is a ipsec tunnel between Router and Xn for all n=3D1 to 50. I=
 copy=20
files from Rn to H. I start the copy from H, so the tcp-connections get=
=20
established from H to Rn.

The same test works just fine with 3.4.63. All cores are used but no on=
e=20
reaches its limit. The router does neither drop pings nor does it have=20
problems pinging other targets.

I tested 3.8.13 It seems not to have this issue if I increase

	net.ipv4.inet_peer_threshold

(I tried 6566400, didn't try smaller values beside the default one).

If I use the default one 3.8.13 behaves badly.

But 3.8.13 seems to have other issues. Basically: routing stalls later =
much=20
longer (up to 6 minutes or so).



*** Environment:

It's a 8 core machine (with AES-NI). It establishes a lot of ipsec-tunn=
els. It=20
uses statefull packet filtering (but no NAT). The network-cards are int=
el=20
cards (driver: igb and ixgbe). No IPv6. No ethernet flow control enable=
d (but=20
doesn't matter). No traffic shaping (that is tc). igb/ixgbe interfaces:=
=20
nothing modified with ethtool but flow control (autoneg off tx off rx o=
ff).


Any idea?


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
