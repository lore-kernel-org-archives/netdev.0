From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] icmp: Remove some spurious dropped packet profile
 hits from the ICMP path
Date: Fri, 14 Nov 2014 08:16:57 -0800
Message-ID: <54662AF9.4050002@hp.com>
References: <20141113225457.A3E502900805@tardy> <1415931471.17262.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:21692 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161009AbaKNQRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 11:17:00 -0500
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com [15.192.137.9])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 195FA3EF5
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 16:17:00 +0000 (UTC)
In-Reply-To: <1415931471.17262.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This looks quite complicated to me.
>
> Why are you adding kfree_skb() everywhere instead of :
>
> 	bool to_consume = icmp_pointers[icmph->type].handler(skb);
> 	if (ro_consume)
> 		consume_skb(skb);
> 	else
> 		kfree_skb(skb);

I thought the point of the drop profiling was to show where the drops 
were happening.  Leaving the kfree_skb() up in icmp_rcv() does not 
improve showing where the drops happened.  That is why I've pushed it 
down into the routines called by icmp_rcv().

rick
