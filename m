From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 13:58:51 -0400 (EDT)
Message-ID: <20141010.135851.1743803688676076555.davem@davemloft.net>
References: <5437F7CB.5010101@redhat.com>
	<1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<54380E49.5050504@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbaJJR6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:58:53 -0400
In-Reply-To: <54380E49.5050504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 10 Oct 2014 09:50:17 -0700

> If I just use get_unaligned that is pretty easy in terms of cleanup
> for the ports and IPv4 addresses, the IPv6 will still be a significant
> hurdle to overcome though.

Actually, it's not that simple.

When the compiler sees things like "th->doff" it will load the 32-bit
word that 4-bit field contains and extract the value using shifts and
masking.

So we might need to sprinkle a "attribute((packed))" here and there
to make it work.
