From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 13 Feb 2009 14:51:48 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902131448040.9310@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:54529 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbZBMNvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 08:51:51 -0500
In-Reply-To: <20090213130347.GD23879@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-02-13 14:03, Evgeniy Polyakov wrote:
>> >What's this? It does not exist in the net/ipv4/netfilter/Kconfig
>> 
>> net/netfilter/Kconfig: (e.g.)
>> 
>> config NETFILTER_XT_MATCH_COMMENT
>>         tristate  '"comment" match support'
>>         depends on NETFILTER_ADVANCED
>>         ---help---
>
>But I placed OSF into net/ipv4/netfilter/ipt_osf.c, should it be moved
>into different location?

That would be preferable -> net/netfilter/xt_osf.c.

>> >> >+					case OSFOPT_MSS:
>> >> >+						mss = ntohs(*(u16 *)(optp + 2));
>> >> 
>> >> This needs get_unaligned(), in case someone sends a malicious packet.
>> >
>> >Hmmm, why is this needed? We dereference linear kernel pointer at
>> >proper offset (modulo of the option size).
>> 
>> What if optp is odd?
>
>It cant, header is fixed and every option length is also fixed (and its
>size is checked).

This RFC-compliant ("An option may begin on any octet boundary.")
option byte stream seems to produce an odd optp value:

01 02 04 05 a0 00

or where did I go wrong?
