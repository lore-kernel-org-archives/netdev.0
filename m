From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 23:04:14 -0700
Message-ID: <1369721054.3301.531.camel@edumazet-glaptop>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
	 <51A39A3F.8080903@redhat.com> <1369693520.3301.477.camel@edumazet-glaptop>
	 <1369715506.2034.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	aquini@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:35187 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932969Ab3E1GER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:04:17 -0400
In-Reply-To: <1369715506.2034.30.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-27 at 21:31 -0700, Joe Perches wrote:

> I think the __alloc_skb alloc failure message is ok,
> but maybe there shouldn't be something "scary" like
> a dump_stack.
> 
> Maybe this site should use a trivial debug error
> message like below instead.
> ---

Oh well.

If dump_stack are scary, they are scary for every k[mz]alloc() users,
not only __alloc_skb_alloc()

I just said : Please do not add GFP_NOWARN to thousand of call sites,
and you suggest adding more code in network fast path. (???)

This is not a trivial code, we are speaking of a very sensitive one.

Let mm guys explain in what cases a full stack trace is nice to have,
and in what cases its useless. An heuristic should be defined in mm tree
for that, and not spread everywhere.

There must be a reason GFP_NOWARN is seldom used in the kernel, even if
most callers are able to recover properly from a failed memory
allocation.
