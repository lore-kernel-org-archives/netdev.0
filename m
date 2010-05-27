From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP Fragmentation and DF bit..
Date: Thu, 27 May 2010 11:43:35 +0200
Message-ID: <87bpc11xyw.fsf@basil.nowhere.org>
References: <C8231CDB.16FC5%pradeepv@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Vincent\, Pradeep" <pradeepv@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60900 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab0E0Jnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 05:43:41 -0400
In-Reply-To: <C8231CDB.16FC5%pradeepv@amazon.com> (Pradeep Vincent's message of "Wed\, 26 May 2010 18\:45\:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Vincent, Pradeep" <pradeepv@amazon.com> writes:

> OMan 7 ip=B9 declares that =B3The  system-wide  default  is  controll=
ed  by  the
> ip_no_pmtu_disc  sysctl  for SOCK_STREAM  sockets,  and  disabled  on=
 all
> others.=B2 which led me to think ODF=B9 bit will not be set for UDP p=
ackets.
> But..

One should add ip.7 is not really a spec, just documentation
how things were quite a few years ago. It unfortunately
does often not get updated when things change.

>
> In a network environment where MTU-big and MTU-small co-exist (and ha=
ve
> router=B9s fragmentation turned off in favor of PMTU discovery), UDP =
packets
> that are > MTU-small and < MTU-big find the PMTU effectively but UDP
> packets


I don't understand your mtu-small/big concept. PMTU is per IP and per
flow. So there's only always a single PMTU, not small and big.

Or do you refer to a single IP NAT situation where a single IP
shares different MTUs?

> Is there a reason ODF=B9 bit cannot be set on fragmented packets on U=
DP
> transmission ? I couldn=B9t find anything in RFC for IP protocol that
> prohibited DF bit on fragmented packets. Did I miss
> something here ?

> Would it be reasonable if PMTU discovery is performed (DF bit set +
> appropriate icmp logic) even for locally fragmented packets ? I think
> this


DF=3D1 on fragments would mean the application has to do pmtu discovery
even with fragments for the case when the kernel does not know=20
the path mtu yet. But if the app supports pmtu discovery it's better
to not use fragments in the first place.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
