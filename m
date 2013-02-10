From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sun, 10 Feb 2013 19:57:57 +0900
Message-ID: <51177D35.8030209@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210095954.GA23548@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@wide.ad.jp>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57236 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751179Ab3BJK57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:57:59 -0500
In-Reply-To: <20130210095954.GA23548@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> On Sat, Feb 09, 2013 at 11:12:46PM +0900, YOSHIFUJI Hideaki wrote:
>> It seems applications will join ff01::/16%eth0 instead of ff01::/16%lo.
>> If so, your original patch seems better.  My bad, sorry.
>>
>> Would you update original one, with minor modification that defers
>> kfree_skb() after incrementing MIB, please?
> 
> I would add another constraint to the if "&& !(dev->flags & IFF_LOOPBACK)", so
> it becomes:
> 
>                 if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
>                     IPV6_ADDR_SCOPE_NODELOCAL &&
>                     !(dev->flags & IFF_LOOPBACK))
>                         kfree_skb(skb);
>                         return 0;
>                 }
> 
> 
> Otherwise ff01::/16%lo would not work because the multicast mirroring through
> dev_loopback_xmit won't be taken and the packet would be dropped after that.
> 
> Can you confirm? Thanks.

Ack.

--yoshfuji
