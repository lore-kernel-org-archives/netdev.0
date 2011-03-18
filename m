From: Brian Haley <brian.haley@hp.com>
Subject: Re: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Thu, 17 Mar 2011 21:26:51 -0400
Message-ID: <4D82B4DB.2060006@hp.com>
References: <1300357750.2589.46.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Yuniverg, Michael" <michael.yuniverg@intel.com>,
	"Yedvab, Nadav" <nadav.yedvab@intel.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:39763 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296Ab1CRB0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 21:26:54 -0400
In-Reply-To: <1300357750.2589.46.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2011 06:29 AM, David Woodhouse wrote:
> We've discovered strange behaviour when we listen on in6addr_any and =
use
> SO_BINDTODEVICE to bind to the lo device.
>=20
> We can connect to any IPv4 address that is local to the machine, on a=
ny
> interface. (This is true whether we listen on AF_INET6/in6addr_any an=
d
> accept IPv4 connections on the IPv6 socket, or whether we just listen=
 on
> AF_INET/INADDR_ANY).
>=20
> The IPv6 behaviour is different =E2=80=94 the only IPv6 address that =
we can
> connect to is ::1.
>=20
> See attached test case, which listens with SO_BINDTODEVICE as describ=
ed.
> Note that it needs to be run as root because SO_BINDTODEVICE is a
> privileged operation.
>=20
> Why this difference? Ideally, we want the Legacy IP behaviour to happ=
en
> for IPv6 too; we want local clients to be able to connect to *any* lo=
cal
> IP address to talk to our service, but we don't want to accept
> connections from the outside.
>=20
<snip>

> telnet> close
> Connection closed.
> [root@macbook dwmw2]# telnet 2001:8b0:10b:1:216:eaff:fe05:bbb8 9999
> Trying 2001:8b0:10b:1:216:eaff:fe05:bbb8...
> telnet: connect to address 2001:8b0:10b:1:216:eaff:fe05:bbb8: Connect=
ion refused
> telnet: Unable to connect to remote host: Connection refused

Hmm, "connection refused", do you have any iptables rules installed?  C=
onnecting
to a local global address worked fine for me on 2.6.32-30 using a home-=
grown
test app.

BTW, the one difference you will see with this is that trying to connec=
t to
a link-local won't work without specifying a scope (like an interface),=
 so
that is different than IPv4.

-Brian
