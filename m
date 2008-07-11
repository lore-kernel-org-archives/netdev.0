From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from unjoined groups
Date: Fri, 11 Jul 2008 21:44:44 +0300
Message-ID: <200807112144.45018.rdenis@simphalempin.com>
References: <20080711152112.GA4534@hmsreliant.think-freely.org> <OF6F2387F9.1EAA3BCD-ON88257483.005E2CF9-88257483.005EE681@us.ibm.com> <20080711173549.GC4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>, davem@davemloft.net,
	jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38759 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427AbYGKSos convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 14:44:48 -0400
In-Reply-To: <20080711173549.GC4534@hmsreliant.think-freely.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 11 juillet 2008 20:35:49 Neil Horman, vous avez =E9crit=A0:
> So you're saying that if I take a process, call bind, specifying
> INADDR_ANY, and then call setsockopt(...,IP_ADD_MEMBERSHIP,...) speci=
fying
> a multicast group X, that I can expect to recieve messages from other
> multicast addresses that other processes in the system have joined to=
?=20

Yes, he says so. I am not aware of a real standard for the IPv4 socket =
API:=20
POSIX and IETF only defined the IPv6 multicast API, it seems. That bein=
g=20
noted, the Linux behavior is in accordance with RFC3493:

|     IPV6_JOIN_GROUP
|
|        Join a multicast group on a specified local interface.
|        If the interface index is specified as 0,
|        the kernel chooses the local interface.
|        For example, some kernels look up the multicast group
|        in the normal IPv6 routing table and use the resulting
|        interface.

Note the use of *interface* rather than *socket* here. And then:

|  Note that to receive multicast datagrams a process must join the
|  multicast group to which datagrams will be sent.  UDP applications
|  must also bind the UDP port to which datagrams will be sent.  Some
|  processes also bind the multicast group address to the socket, in
|  addition to the port, to prevent other datagrams destined to that
|  same port from being delivered to the socket.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
