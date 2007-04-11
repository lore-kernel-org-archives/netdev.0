From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Wed, 11 Apr 2007 07:47:26 +0200
Message-ID: <461C766E.5030107@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329029E454C@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44157 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbXDKFsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 01:48:18 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E454C@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>This leaks the device. You treat every single-queue device as 
>>having a single subqueue. If it doesn't get too ugly it would 
>>be nice to avoid this and only allocate the subqueue states 
>>for real multiqueue devices.
> 
> 
> We went back and forth on this.  The reason we allocate a queue in every
> case, even on single-queue devices, was to make the stack not have
> branching for multiqueue and non-multiqueue devices.  If we don't have
> at least one queue on a device, then we can't have
> netif_subqueue_stopped() in the hotpath unless we check if a device is
> multiqueue before.  The original patches I released had this branching,
> and I was asked to not do that.


OK, thanks for the explanation.

>>>+			skb->queue_mapping =
>>>+				 q->prio2band[q->band2queue[band&TC_PRIO_MAX]];
>>
>>
>>Does this needs to be cleared at some point again? TC actions 
>>might redirect or mirror packets to other (multiqueue) devices.
> 
> 
> If an skb is redirected to another device, the skb should be filtered
> through that device's qdisc, yes?


Yes, but the device might not have a queue or use something different
than prio, so the value would stay the same. I think you need to clear
it before enqueueing a packet or alternatively when redirecting in the
mirred action.

