From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 30 Jan 2009 16:47:33 +0100
Message-ID: <87ocxox0bu.fsf@basil.nowhere.org>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com>
	<497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com>
	<497ED0A2.6050707@trash.net> <497F350A.9020509@cosmosbay.com>
	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com>
	<497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com>
	<498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net>
	<498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com>
	<4981CBE2.5020306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57259 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbZA3PsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 10:48:04 -0500
In-Reply-To: <4981CBE2.5020306@cosmosbay.com> (Eric Dumazet's message of "Thu, 29 Jan 2009 16:31:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:

> While doing oprofile tests I noticed two loops are not properly unrolled by gcc

That's because nobody passed -funroll-loops. Did you try that for
that file? Likely will need -O2 too

> +static unsigned long ifname_compare(const void *_a, const void *_b, const void *_mask)
> +{
> +	const unsigned long *a = (const unsigned long *)_a;
> +	const unsigned long *b = (const unsigned long *)_b;
> +	const unsigned long *mask = (const unsigned long *)_mask;
> +	unsigned long ret;
> +
> +	ret = (a[0] ^ b[0]) & mask[0];
> +	ret |= (a[1] ^ b[1]) & mask[1];
> +	if (IFNAMSIZ > 2 * sizeof(unsigned long))
> +		ret |= (a[2] ^ b[2]) & mask[2];
> +	if (IFNAMSIZ > 3 * sizeof(unsigned long))
> +		ret |= (a[3] ^ b[3]) & mask[3];

That will silently break for IFNAMSIZ >= 4*sizeof(unsigned long)
You should add a dummy loop for that or at least a BUILD_BUG_ON

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
