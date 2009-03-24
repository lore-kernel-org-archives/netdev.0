From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in
 arp_packet_match()
Date: Tue, 24 Mar 2009 13:29:54 -0700 (PDT)
Message-ID: <20090324.132954.148903398.davem@davemloft.net>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
	<20090324140312.31401.89168.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754822AbZCXUaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 16:30:06 -0400
In-Reply-To: <20090324140312.31401.89168.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Mar 2009 15:03:16 +0100 (MET)

> +/*
> + * Unfortunatly, _b and _mask are not aligned to an int (or long int)
> + * Some arches dont care, unrolling the loop is a win on them.
> + */
> +static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
> +{
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	const unsigned long *a = (const unsigned long *)_a;
> +	const unsigned long *b = (const unsigned long *)_b;

I think we can at least give some help for the platforms which
require alignment.

We can, for example, assume 16-bit alignment and thus loop
over u16's
