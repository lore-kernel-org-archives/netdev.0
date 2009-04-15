From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 23:07:29 +0200
Message-ID: <49E64C91.5020708@cosmosbay.com>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com>	<20090413095309.631cf395@nehalam>	<49E48136.5060700@trash.net>	<49E49C65.8060808@cosmosbay.com>	<20090414074554.7fa73e2f@nehalam>	<49E4B0A5.70404@cosmosbay.com>	<b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com>	<20090414111716.28585806@nehalam>	<49E4E3E8.5090201@cosmosbay.com>	<20090414141351.0f63ac98@nehalam>	<49E502B5.7070700@cosmosbay.com>	<49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53357 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196AbZDOVJF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 17:09:05 -0400
In-Reply-To: <20090415135526.2afc4d18@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Looks like there is some recursive path into ip_tables that makes the
> per-cpu spinlock break.  I get lockup's with KVM networking.
>=20
> Suggestions?

Well, it seems original patch was not so bad after all

http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/02317=
5.html

So change per-cpu spinlocks to per-cpu rwlocks=20

and use read_lock() in ipt_do_table() to allow recursion...


