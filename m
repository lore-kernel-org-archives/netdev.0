From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in
 arp_packet_match()
Date: Tue, 24 Mar 2009 14:18:48 -0700 (PDT)
Message-ID: <20090324.141848.119353425.davem@davemloft.net>
References: <20090324.132954.148903398.davem@davemloft.net>
	<49C94B6A.5020304@cosmosbay.com>
	<alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>
Date: Tue, 24 Mar 2009 22:17:17 +0100 (CET)

> 
> On Tuesday 2009-03-24 22:06, Eric Dumazet wrote:
> >>> +/*
> >>> + * Unfortunatly, _b and _mask are not aligned to an int (or long int)
> >>> + * Some arches dont care, unrolling the loop is a win on them.
> >>> + */
> >>> +static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
> >>> +{
> >>> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> >>> +	const unsigned long *a = (const unsigned long *)_a;
> >>> +	const unsigned long *b = (const unsigned long *)_b;
> >> 
> >> I think we can at least give some help for the platforms which
> >> require alignment.
> >> 
> >> We can, for example, assume 16-bit alignment and thus loop
> >> over u16's
> >
> >Right. How about this incremental patch ?
> >
> >Thanks
> >
> >[PATCH] arp_tables: ifname_compare() can assume 16bit alignment
> >
> >Arches without efficient unaligned access can still perform a loop
> >assuming 16bit alignment in ifname_compare()
> 
> Allow me some skepticism, but the code looks pretty much like a
> standard memcmp.

memcmp() can't make any assumptions about alignment.
Whereas we _know_ this thing is exactly 16-bit aligned.

All of the optimized memcmp() implementations look for
32-bit alignment and punt to byte at a time comparison
loops if things are not aligned enough.
