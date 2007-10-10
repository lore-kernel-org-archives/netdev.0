From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Evict tmp variable from the stack in ip6_evictor
Date: Wed, 10 Oct 2007 18:52:20 +0400
Message-ID: <470CE724.8030807@openvz.org>
References: <470CE1C8.9020000@openvz.org> <470CE38C.2020607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47952 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbXJJOzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 10:55:01 -0400
In-Reply-To: <470CE38C.2020607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> The list_head *tmp is used to help getting the first entry in
>> the ip6_frag_lru_list list. There is a simpler way to do it
> 
> 
> The exact same code exists in ip_fragment.c and nf_conntrack_reasm.c,
> please also change it there.

Hm, indeed. But I see that the structs frag_queue in reassembly.c, ipq 
in ip_fragment.c and nf_ct_frag6_queue in nf code looks VERY similar 
and very much of code (like link/unlink or evict) looks the same too.

Maybe it's worth creating something like struct skb_fragment and
consolidate all the common stuff into some net/core/lib_frag.c? Or
is there some hidden reason for keeping this code splitted?

Thanks, 
Pavel
