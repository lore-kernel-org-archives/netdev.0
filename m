From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 20:53:19 +0200
Message-ID: <467C1A9F.5060004@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903178F0B@orsmsx414.amr.corp.intel.com> <467C1800.2020103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36661 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759217AbXFVSyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 14:54:03 -0400
In-Reply-To: <467C1800.2020103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
> 
>>Thought about this more last night and this morning.  As far as I can
>>tell, I still need this.  If the qdisc gets loaded with multiqueue
>>turned on, I can just use the value of band to assign
>>skb->queue_mapping.  But if the qdisc is loaded without multiqueue
>>support, then I need to assign a value of zero to queue_mapping, or not
>>assign it at all (it will be zero'd out before the call to ->enqueue()
>>in dev_queue_xmit()).  But I'd rather not have a conditional in the
>>hotpath checking if the qdisc is multiqueue; I'd rather have the array
>>to match the bands so I can just do an assignment.
>>
>>What do you think?
> 
> 
> 
> I very much doubt that it has any measurable impact. You can
> also add a small inline function
> 
> void skb_set_queue_mapping(struct sk_buff *skb, unsigned int queue)


OK I didn't really listen obviously :) A compile time option
won't help. Just remove it and assign it conditionally.
