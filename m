From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Allow fragmentation of VLAN packets traversing a bridge.
Date: Fri, 17 Apr 2009 19:20:40 +0200
Message-ID: <49E8BA68.50605@trash.net>
References: <49E89E0D.5080000@gmail.com> <49E8A6DF.3040905@trash.net> <49E8B73C.7080004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Saikiran Madugula <hummerbliss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58415 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756815AbZDQRUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 13:20:43 -0400
In-Reply-To: <49E8B73C.7080004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saikiran Madugula wrote:
> Patrick McHardy wrote:
>>> -    if (skb->protocol == htons(ETH_P_IP) &&
>>> +    if ((skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb)) &&
>>>          skb->len > skb->dev->mtu &&
>>>          !skb_is_gso(skb))
>>>          return ip_fragment(skb, br_dev_queue_push_xmit);
>> Please add an additional check for skb->nfct != NULL to make sure
>> that this only refragments packets defragmented by conntrack.
> 
> Thanks for the feedback, skb->nfct is present only if CONFIG_NF_CONNTRACK or
> CONFIG_NF_CONNTRACK_MODULE is defined. Was wondering if the entire check before
> ip_fragment is necessary if NF_CONNTRACK is not defined. If not, I will post
> updated patch as per your suggestion.

Good point. Yes, everything related to fragmenting is only needed
with NF_CONNTRACK, so an additional ifdef makes sense.

