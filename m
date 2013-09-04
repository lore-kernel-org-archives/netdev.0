From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in
 tcp_v6_do_rcv
Date: Wed, 04 Sep 2013 14:57:04 -0400 (EDT)
Message-ID: <20130904.145704.1474150306960456668.davem@davemloft.net>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448Ab3IDS5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:57:06 -0400
In-Reply-To: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  3 Sep 2013 19:29:12 +0200

> In tcp_v6_do_rcv() code, when processing pkt options, we soley work
> on our skb clone opt_skb that we've created earlier before entering
> tcp_rcv_established() on our way. However, only in condition ...
> 
>   if (np->rxopt.bits.rxtclass)
>     np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
> 
> ... we work on skb itself. As we extract every other information out
> of opt_skb in ipv6_pktoptions path, this seems wrong, since skb can
> already be released by tcp_rcv_established() earlier on. When we try
> to access it in ipv6_hdr(), we will dereference freed skb.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
