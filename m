From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Thu, 3 Apr 2014 16:07:21 +0400
Message-ID: <533D4EF9.60608@securitycode.ru>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:29580 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbaDCMGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2014 08:06:40 -0400
In-Reply-To: <20140403115809.GA13354@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.04.2014 15:58, Hannes Frederic Sowa wrote:
> On Thu, Apr 03, 2014 at 03:37:33PM +0400, Ilya V. Matveychikov wrote:
>> Looking through the code gives me that rt_pmtu is always 0 for the skb->dst
>> entry and ipv4_mtu that called via the dst->ops->mtu() uses dev->mtu :(
> 
> At this point you have to drop skb_dst and have to relookup the route. During
> that a new dst will be created which gets the mtu value from the next hop
> exception, which got created by update_pmtu.
> 
> Normally routes are checked with dst_check if they are still valid
> and a relookup should happen. In your example just do the relookup
> unconditionally.
> 

Does it mean that the next packet must have an updated route without any
problems? I meant that if the first packet xmitting leads to updating the route
PMTU via the exception creating (or updating) so the next packets must have an
updated route? Am I right?
