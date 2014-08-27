From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 14:31:12 +0200
Message-ID: <1409142672.26515.24.camel@localhost>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50835 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756061AbaH0MbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 08:31:15 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2253420A43
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:31:15 -0400 (EDT)
In-Reply-To: <20140825.163458.1117073971092495452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-08-25 at 16:34 -0700, David Miller wrote:
> Given Jesper's performance numbers, it's not the way to go.
> 
> Instead, go with a signalling scheme via new boolean skb->xmit_more.
> 
> This has several advantages:
> 
> 1) Nearly trivial driver support, just protect the tail pointer
>    update with the skb->xmit_more check.

One thing one should keep in mind is, that there must be a skb available
to trigger the flush, maybe this will hurt us one day.

Thinking more about it should we go with a coccinelle script and
replace/extend ndo_start_xmit with an additional argument?

We can also add a new function pointer and call that instead of
ndo_start_xmit. I think only the callq *%rax hurts performance.

Bye,
Hannes
