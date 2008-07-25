From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 19:46:44 +0200
Message-ID: <20080725174644.GA3005@ami.dom.local>
References: <20080719233506.12596.59935.stgit@fate.lan> <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725152932.93641c4o5qk1sx0g@hayate.ip6> <20080725125414.GB25369@ff.dom.local> <20080725161503.67994cpfp4jouz7k@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:37603 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbYGYRqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 13:46:38 -0400
Received: by ug-out-1314.google.com with SMTP id h2so20537ugf.16
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 10:46:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080725161503.67994cpfp4jouz7k@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 04:15:03PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
...
>> Is it's really needed? Actually, if it's only for stats, I really
>> can't see the reason why not to get this info old way - before
>> enqueing? (And this could be not enough if we want packets count
>> like in htb.)
>>
>
> qdisc_enqueue recalculates packet size if inner qdisc has size table  
> set, so qdisc_pkt_len might return different length after qdisc_enqueue 
> than what it was before.

The question is how much does it matter for statistics. Packets' size
(and number) can change many times in many places. Does it mean all
these places should count the same or "real" size? But, if it's really
necessary here, IMHO, it should be done "clean" way, like additional
parameter(s) to qdisc_enqueue(), because in cases like NET_XMIT_CN we
don't even know what happened with an skb.

Jarek P.
