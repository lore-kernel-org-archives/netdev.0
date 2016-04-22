From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Fri, 22 Apr 2016 05:39:40 -0700
Message-ID: <1461328780.7627.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160421074042.GF3347@gauss.secunet.com>
	 <1461243546.7627.15.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160422091328.GK3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:34157 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcDVMjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 08:39:43 -0400
Received: by mail-vk0-f54.google.com with SMTP id e185so133933324vkb.1
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 05:39:43 -0700 (PDT)
In-Reply-To: <20160422091328.GK3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-22 at 11:13 +0200, Steffen Klassert wrote:
> On Thu, Apr 21, 2016 at 05:59:06AM -0700, Eric Dumazet wrote:

> > Here at Google, we increased MAX_SKB_FRAGS, but this is a rather
> > intrusive change to be upstreamed :(
> 
> I've played here with MAX_SKB_FRAGS too, but it seems to
> be device specific how many page fragments it can handle.
> I wonder if we could increase MAX_SKB_FRAGS at the GRO
> layer and let GSO split this buffer in something that
> the transmitting device can handle?

Yes, the same principle would apply.

Split a GRO packet into X TSO packets with whatever number of frags.

bnx2x has to linearize some skbs having more than 13 frags.
