From: "Stian Skjelstad" <stian@nixia.no>
Subject: SV: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer address. Bug or feature?
Date: Fri, 13 Apr 2012 15:59:34 +0200
Message-ID: <023e01cd197d$a9faba40$fdf02ec0$@no>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "'Denys Fedoryshchenko'" <denys@visp.net.lb>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail48.e.nsc.no ([193.213.115.48]:37484 "EHLO mail48.e.nsc.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852Ab2DMOLL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 10:11:11 -0400
In-Reply-To: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
Content-Language: no
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've seen the same issue, and got no response so far to that very same =
question. Have you tested this on older kernels? I have worked around t=
his issue by testing my local copy of routing entries that use 'via'. I=
f they are not routable when after the RTM_DELROUTE event, I autoremove=
 them from my local copy.

Stian Skjelstad

-----Opprinnelig melding-----
=46ra: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g] P=C3=A5 vegne av Denys Fedoryshchenko
Sendt: 13. april 2012 14:11
Til: netdev@vger.kernel.org
Emne: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer a=
ddress. Bug or feature?

Hi

I am trying to implement my own routing daemon, and using RTMGRP_IPV4_R=
OUTE to monitor routes.
I notice, that on PPPoE, when interface disappearing, RTM_DELROUTE will=
 be sent to listener only for local address, but nothing about peer add=
ress attached to this interface.

CBSS_PPPoE ~ # ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol
           inet addr:172.16.146.1  P-t-P:172.16.146.10
Mask:255.255.255.255
           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1200  Metric:1
           RX packets:40439 errors:0 dropped:0 overruns:0 frame:0
           TX packets:63211 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:3
           RX bytes:3584507 (3.4 MiB)  TX bytes:47180929 (44.9 MiB)

CBSS_PPPoE ~ # pppkill tek234@visp.net.lb  (this is killing pppd proces=
s for ppp0 interface)

ip monitor route will show only RTM_DELROUTE for RTN_LOCAL, but nothing=
 about RTN_UNICAST for 172.16.146.10.
"Deleted local 172.16.146.1 dev ppp0  table local  proto kernel  scope =
host  src 172.16.146.1"
My program also receive same.

Is it a bug, that no RTM_DELROUTE issued for peer ip address? Or should=
 i monitor also RTMGRP_IPV4_IFADDR for link disappearance?

Thanks for help!
--
To unsubscribe from this list: send the line "unsubscribe netdev" in th=
e body of a message to majordomo@vger.kernel.org More majordomo info at=
  http://vger.kernel.org/majordomo-info.html
