From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: make sure neighbour code can push
 ethernet header
Date: Sun, 01 Mar 2015 00:30:00 -0500 (EST)
Message-ID: <20150301.003000.2087464960859465969.davem@davemloft.net>
References: <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F123C4.2030907@vultr.com>
	<1425090935.5130.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brak@vultr.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbCAFaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 00:30:01 -0500
In-Reply-To: <1425090935.5130.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Feb 2015 18:35:35 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Brian reported crashes using IPv6 traffic with macvtap/veth combo.
> 
> I tracked the crashes in neigh_hh_output()
> 
> -> memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
> 
> Neighbour code assumes headroom to push Ethernet header is
> at least 16 bytes.
> 
> It appears macvtap has only 14 bytes available on arches
> where NET_IP_ALIGN is 0 (like x86)
> 
> Effect is a corruption of 2 bytes right before skb->head,
> and possible crashes if accessing non existing memory.
> 
> This fix should also increase IPv4 performance, as paranoid code
> in ip_finish_output2() wont have to call skb_realloc_headroom()
> 
> Reported-by: Brian Rak <brak@vultr.com>
> Tested-by: Brian Rak <brak@vultr.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
