From: Patrick McHardy <kaber@trash.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 17:23:03 +0200
Message-ID: <48889E57.2000007@trash.net>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu> <20080724142353.GA400@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Krzysztof Piotr Oledzki <ole@ans.pl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40347 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbYGXPXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 11:23:07 -0400
In-Reply-To: <20080724142353.GA400@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> Then i tried both suggested fix patches Patrick sent me (a suggested 
> revert and an netfilter/RCU use-after-free fix), but none of them solved 
> the crash.

Just to make sure - the "netfilter/RCU use-after-free fix" was the
patch from Pekka?

> Thus i finally arrived to:
> 
>  # good: [ae6134bd] hdlcdrv: Fix CRC calculation.
>  # bad:  [5547cd0d] netfilter: nf_conntrack_sctp: fix sparse warnings
>  # bad:  [280763c6] netfilter: xt_time: fix time's time_mt()'s use of
>  # good: [07a7c10b] netlink: add NLA_PUT_BE64 macro
>  # bad:  [58401573] netfilter: accounting rework: ct_extend + 64bit co
> 
> | 584015727a3b88b46602b20077b46cd04f8b4ab3 is first bad commit
> | commit 584015727a3b88b46602b20077b46cd04f8b4ab3
> | Author: Krzysztof Piotr Oledzki <ole@ans.pl>
> | AuthorDate: Mon Jul 21 10:01:34 2008 -0700
> | Commit:     David S. Miller <davem@davemloft.net>
> | CommitDate: Mon Jul 21 10:10:58 2008 -0700
> |
> |    netfilter: accounting rework: ct_extend + 64bit counters (v4)
> [...]
> |     Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
> |     Signed-off-by: Patrick McHardy <kaber@trash.net>
> |     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Which i double-checked by reverting that commit from -git as well and 
> that solved the crash. Find the tested reverter patch below.

Thats odd. I don't think anything is wrong with that patch
itself, its more likely that its triggering a bug in
ct_extend. You config has a few helper enabled (FTP, H.323,
TFTP) and the crash is when trying to call the helper functions.
Did you actually have traffic of one of these protocols?

