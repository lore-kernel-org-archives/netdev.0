From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 23:58:54 +0200
Message-ID: <46803A9E.40705@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903179DB2@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47837 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbXFYV7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 17:59:41 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903179DB2@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>> @@ -70,14 +72,28 @@ prio_classify(struct sk_buff *skb, struct Qdisc 
>>> *sch, int *qerr)  #endif
>>>  			if (TC_H_MAJ(band))
>>>  				band = 0;
>>> +			if (q->mq)
>>> +				skb->queue_mapping = 
>>> +						
>>>       
>> q->prio2band[band&TC_PRIO_MAX];
>>     
>>> +			else
>>> +				skb->queue_mapping = 0;
>>>       
>> Might look cleaner if you have one central point where 
>> queue_mapping is set and the band is returned.
>>     
>
> I've taken a stab at this.  I can have one return point, but I'll still
> have multiple assignments of skb->queue_mapping due to the different
> branches for which queue to select in the qdisc.  I suppose we can do a
> rewrite of prio_classify(), but to me that seems beyond the scope of the
> multiqueue patches themselves.  What do you think?
>   

Thats not necessary. I just though you could add one exit point:


...
out:
    skb->queue_mapping = q->mq ? band : 0;
    return q->queues[band];
}

But if that doesn't work don't bother ..

