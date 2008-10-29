From: David Miller <davem@davemloft.net>
Subject: Re: New filter 'flow' bug?
Date: Wed, 29 Oct 2008 00:37:13 -0700 (PDT)
Message-ID: <20081029.003713.193704291.davem@davemloft.net>
References: <20081029072705.376AC1E3087@f03.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: almaop@poczta.fm
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752257AbYJ2Hhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 03:37:38 -0400
In-Reply-To: <20081029072705.376AC1E3087@f03.poczta.interia.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: almaop@poczta.fm
Date: 29 Oct 2008 08:27:05 +0100

Deeply technical questions are almost certainly going to get zero
response on linux-net.  So using netdev is generally a better idea
since that actually gets to the networking developers.

Added to CC:

> Hi. I'm using this new "flow" filter:
> (http://www.mail-archive.com/netdev@vger.kernel.org/msg60638.html). It is configuration as above: tc filter flow classify packets in the sfq. It works (as it seems) fine. But only until there is some traffic in the queue. When there is some interruption in the packets flow (for a while) something goes wrong and the queue blocks. From that moment onward nothing goes trough. It is very annoying. You have to remove sfq to resume traffic.
> Is anybody using this new filter which sfq?
> My configuration: gentoo, kernel 2.6.26.7 + imq patch + l7 patch, glibc 2.7, iproute2 2.6.26. Shaping is done on ethernet (e1000 card) but as I see on the ifb nothing changes.
> There are htb 3 classes with sfq as their qdiscs. It is simple, something like:
> 
> tc qdisc add dev $DEV root handle 1: htb default 4 tc class add dev $DEV parent 1: classid 1:1 htb rate 78kbps ceil 78kbps overhead 0 linklayer atm
> 
> tc class add dev $DEV parent 1:1 classid 1:2 htb rate 20kbps ceil 20kbps overhead 0 linklayer atm prio 3
> tc class add dev $DEV parent 1:1 classid 1:3 ...
> tc class add dev $DEV parent 1:1 classid 1:4 ...
>  
> tc qdisc add dev $DEV parent 1:2 handle 2: sfq quantum 64
> tc qdisc add dev $DEV parent 1:3 handle 3: sfq
> tc qdisc add dev $DEV parent 1:4 handle 4: sfq
> 
> tc filter add dev $DEV parent 1: ....
> ....
>  
> tc filter add dev $DEV parent 2: protocol ip handle 1 prio 12 flow \
> hash keys dst,proto,proto-dst divisor 128
> 
> tc filter add dev $DEV parent 3: protocol ip handle 1 prio 12 flow \
> hash keys dst,proto,proto-dst divisor 128
> 
> tc filter add dev $DEV parent 4: protocol ip handle 1 prio 12 flow \
> hash keys nfct-src,nfct-dst,proto,nfct-proto-src,nfct-proto-dst divisor 128
> 
> I'm not sure where is the bug - in the flow filter or in the sfq qdisc.
> 
> Regards
> 
> Krzysiek
> 
> 
> ----------------------------------------------------------------------
> Wymysl wierszyk, wygraj cyfrowke!
> Sprawdz >>> http://link.interia.pl/f1f5a
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
