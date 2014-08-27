From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:45:10 -0700 (PDT)
Message-ID: <20140827.134510.2172564669938048576.davem@davemloft.net>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<1409142672.26515.24.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964892AbaH0UpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:45:12 -0400
In-Reply-To: <1409142672.26515.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 27 Aug 2014 14:31:12 +0200

> On Mo, 2014-08-25 at 16:34 -0700, David Miller wrote:
>> Given Jesper's performance numbers, it's not the way to go.
>> 
>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>> 
>> This has several advantages:
>> 
>> 1) Nearly trivial driver support, just protect the tail pointer
>>    update with the skb->xmit_more check.
> 
> One thing one should keep in mind is, that there must be a skb available
> to trigger the flush, maybe this will hurt us one day.
> 
> Thinking more about it should we go with a coccinelle script and
> replace/extend ndo_start_xmit with an additional argument?
> 
> We can also add a new function pointer and call that instead of
> ndo_start_xmit. I think only the callq *%rax hurts performance.

I don't think we will have any problems here, the caller will always
be the entity which analyzes the upcoming set of SKBs to submit and
tag them properly.

I really do not want to add a new OP and I even more so do not want to
adjust the ndo_start_xmit() signature.  It's effect is far reaching,
and for absolutely no gain as far as I can see.

Thanks.
