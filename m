From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in
 arp_packet_match()
Date: Tue, 24 Mar 2009 22:23:23 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr>
References: <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com> <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr> <20090324.141848.119353425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:48523 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbZCXVX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 17:23:26 -0400
In-Reply-To: <20090324.141848.119353425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-03-24 22:18, David Miller wrote:
>> >
>> >Arches without efficient unaligned access can still perform a loop
>> >assuming 16bit alignment in ifname_compare()
>> 
>> Allow me some skepticism, but the code looks pretty much like a
>> standard memcmp.
>
>memcmp() can't make any assumptions about alignment.
>Whereas we _know_ this thing is exactly 16-bit aligned.
>
>All of the optimized memcmp() implementations look for
>32-bit alignment and punt to byte at a time comparison
>loops if things are not aligned enough.

Yes, I seem to remember glibc doing something like

 if ((addr & 0x03) != 0) {
     // process single bytes (increment addr as you go)
     // until addr & 0x03 == 0.
 }

 /* optimized loop here. also increases addr */

 if ((addr & 0x03) != 0)
     // still bytes left after loop - process on a per-byte basis

Is the cost of testing for non-4-divisibility expensive enough
to warrant not usnig memcmp?

Irrespective of all that, I think putting the interface comparison
code should be agglomerated in a function/header so that it is
replicated across iptables, ip6tables, ebtables, arptables, etc.
