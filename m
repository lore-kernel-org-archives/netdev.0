From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Wed, 18 Feb 2009 17:52:22 +0100
Message-ID: <499C3CC6.9020704@trash.net>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net> <499C3871.4030600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57887 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbZBRQw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 11:52:26 -0500
In-Reply-To: <499C3871.4030600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> In case of IPv4 and IPv6 they are already suitable aligned, it
>> simply performing the comparison in unsigned long quantities.
>> struct arpt_arp unfortunately doesn't properly align the interface
>> names, so we need to continue to do byte-wise comparisons.
>>
> I see, but #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS can help her=
e ;)

get_unaligned() would work as well I guess. But we don't seem to
have a get_unaligned_long().

> ifname_compare() should be static in three files (ipv4_ip_tables, ipv=
6_ip_tables and arp_tables),
> since only arp_tables variant has the alignement problem.
>=20
> [PATCH] netfilter: unfold two critical loops in arp_packet_match()
>=20
> x86 and powerpc can perform long word accesses in an efficient maner.
> We can use this to unroll two loops in arp_packet_match(), to
> perform arithmetic on long words instead of bytes. This is a win
> on x86_64 for example.

This looks good to me. Applied, thanks.
