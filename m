From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Thu, 04 Mar 2010 07:00:31 +0100
Message-ID: <1267682431.2943.10.camel@edumazet-laptop>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian>
	 <1267610843.2997.7.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
	 <1267626678.2997.25.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6BAE@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:33250 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab0CDGAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 01:00:37 -0500
Received: by fxm19 with SMTP id 19so2417605fxm.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 22:00:35 -0800 (PST)
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A45A6BAE@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 mars 2010 =C3=A0 13:21 +0800, Zhu, Yi a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Then its a separate bug. MD5 support added so many bugs its not eve=
n
> > funny.
>=20
> > Existing bugs are not an excuse for adding new ones, we try the rev=
erse.
> > No ?
>=20
> Can you show me where sk_drops is used by TCP and what SNMP MIB value
> should I use for backlog dropping? TCP_MIB_INERRS doesn't seem correc=
t.

sk_drop is not yet used by TCP, because when backlog processing is
performed, TCP state machine has much finer grain capabilities to show
why a packet is dropped. In our backlog drop, we dont examine details o=
f
packet and drop it at a lower level.

Please add a new counter, say LINUX_MIB_TCPBACKLOGDROP :

3 added lines:
- one in "include/linux/snmp.h" to define the MIB name
- one to define its string
- one to perform the increment when actual drop occurs)

A good starting point would be to study recent commit
72032fdbcde8b333e65b3430e1bcb4358e2d6716 from Jamal
(xfrm: Introduce LINUX_MIB_XFRMFWDHDRERROR)

=46or sk_drop, just increment it and we can get it at generic sock leve=
l.

Thanks !


