From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Fwd: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Fri, 11 Jul 2014 17:12:55 +0200
Message-ID: <1836813.giEndUKvmp@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:48864 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaGKPYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 11:24:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

I don't have the original patch email, but please include
the mentioned commit

------------------------------------------
commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
Author: Eric Dumazet <edumazet@google.com>
ipv4: set transport header earlier
------------------------------------------

in the 3.4.x stable tree.

After updating from 3.4.91 to 3.4.96, TCP connections
from Windows 7 clients slowed down to a crawl.
(to be precise: totally unusable)

The commit recommended by Florian Westphal fixes it immediately.

Best regards,
Thomas

----------  Forwarded Message  ----------

Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Friday, 27. June 2014, 11:05:25
From: Florian Westphal <fw@strlen.de>
To: jungwon park <jwpark2@whitecode.co.kr>
CC: netdev@vger.kernel.org

jungwon park <jwpark2@whitecode.co.kr> wrote:
> When using the linux router is turned on GRO, router send the 
'fragmentation
> needed' packets to the sender.

Indeed 8-(

> When I turned off GRO, the router operate normally, and there is no 
problem.
> and with 3.4.91 kernel, the router has no problem.
> 
> I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
> (http://patchwork.ozlabs.org/patch/345509/)
> When I revert this patch, the router has no problem.

Can you please cherry-pick following patch on top of vanilla 3.4.92?
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=21d1196a35f5686c4323e42a62fdb4b23b0ab4a3

commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
Author: Eric Dumazet <edumazet@google.com>
ipv4: set transport header earlier

I think that should fix this bug, it should apply cleanly on top of
3.4.y tree.

[ patch is in 3.11, also backported to 3.10.y tree ]

The problem is that, when dealing with GRO packets, we try to determine
the size of the individual packets.  To do this, we rely on the
transport header.

Unfortunately the transport header is not set for the forward path in 3.4,
so we look at the network header instead.
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
-----------------------------------------
