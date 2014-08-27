From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:43:23 -0700 (PDT)
Message-ID: <20140827.134323.1315329156710015083.davem@davemloft.net>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<20140827141918.198cba38@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964892AbaH0Un1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:43:27 -0400
In-Reply-To: <20140827141918.198cba38@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 27 Aug 2014 14:19:18 +0200

> On Mon, 25 Aug 2014 16:34:58 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> Given Jesper's performance numbers, it's not the way to go.
>> 
>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>> 
>> This has several advantages:
>> 
>> 1) Nearly trivial driver support, just protect the tail pointer
>>    update with the skb->xmit_more check.
>> 
>> 2) No extra indirect calls in the non-deferral cases.
> 
> Even-though it is obvious that this new API skb->xmit_more will not
> hurt performance, especially given skb->xmit_more is always 0 in this
> kernel, I've still run my pktgen performance tests.
> 
> Compared to baseline[1]: (averaged 5609929 pps) (details below signature)
>  * (1/5609929*10^9)-(1/5603728*10^9) = -0.197ns
> 
> As expected, this API does not hurt performance (as -0.197ns is below
> our accuracy levels).
> 
> [1] http://thread.gmane.org/gmane.linux.network/327254/focus=327838

Thanks for validating Jesper :-)
