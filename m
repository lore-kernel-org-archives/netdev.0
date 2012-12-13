From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] ipv6: Change skb->data before using icmpv6_notify()
 to propagate redirect
Date: Thu, 13 Dec 2012 11:37:12 -0800
Message-ID: <1355427432.13796.43.camel@joe-AO722>
References: <50C9BA41.1010507@gmail.com>
	 <20121213.125911.566802923957164958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: djduanjiong@gmail.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46985 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755670Ab2LMThN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 14:37:13 -0500
In-Reply-To: <20121213.125911.566802923957164958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 12:59 -0500, David Miller wrote:
> > +     hdr = (u8 *)ndopts.nd_opts_rh;
> 
> (u8 *)[SPACE]ndopts...

Really?

checkpatch bleats a --strict message:

CHECK: No space is necessary after a cast
#5: FILE: t.c:5:
+
+	bar = *(int *) foo;

It's 2/1 no space v space in drivers/net and net.


$ git grep -E "\*\) " drivers/net net | wc -l
4293
$ git grep -E "\*\)[^ ;]" drivers/net net | wc -l
8261

There are many false positives in the first case,
not too many for the second.

I was a bit surprised about how many of the
first case existed.
