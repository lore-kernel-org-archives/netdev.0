From: "jungwon park" <jwpark2@whitecode.co.kr>
Subject: RE: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Fri, 27 Jun 2014 19:07:25 +0900
Message-ID: <002f01cf91ef$98792080$c96b6180$@whitecode.co.kr>
References: <000201cf9198$3cfa3200$b6ee9600$@whitecode.co.kr> <20140627090525.GA30075@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Florian Westphal'" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.whitecode.co.kr ([211.63.65.34]:57460 "EHLO
	whitecode.co.kr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbaF0KHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:07:03 -0400
In-Reply-To: <20140627090525.GA30075@breakpoint.cc>
Content-Language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good!
When I apply the patch(ipv4: set transport header earlier), there is no
problem.
Thanks, Florian.

-----Original Message-----
From: Florian Westphal [mailto:fw@strlen.de] 
Sent: Friday, June 27, 2014 6:05 PM
To: jungwon park
Cc: netdev@vger.kernel.org
Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)

jungwon park <jwpark2@whitecode.co.kr> wrote:
> When using the linux router is turned on GRO, router send the 
> 'fragmentation needed' packets to the sender.

Indeed 8-(

> When I turned off GRO, the router operate normally, and there is no
problem.
> and with 3.4.91 kernel, the router has no problem.
> 
> I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
> (http://patchwork.ozlabs.org/patch/345509/)
> When I revert this patch, the router has no problem.

Can you please cherry-pick following patch on top of vanilla 3.4.92?
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2
1d1196a35f5686c4323e42a62fdb4b23b0ab4a3

commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
Author: Eric Dumazet <edumazet@google.com>
ipv4: set transport header earlier

I think that should fix this bug, it should apply cleanly on top of 3.4.y
tree.

[ patch is in 3.11, also backported to 3.10.y tree ]

The problem is that, when dealing with GRO packets, we try to determine the
size of the individual packets.  To do this, we rely on the transport
header.

Unfortunately the transport header is not set for the forward path in 3.4,
so we look at the network header instead.
