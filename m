From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xps: must clear sender_cpu before forwarding
Date: Wed, 11 Mar 2015 23:51:34 -0400 (EDT)
Message-ID: <20150311.235134.2179029122534232611.davem@davemloft.net>
References: <5500E52C.7080603@nuclearfallout.net>
	<CANn89iLHkYc2Kay7z+v=tHMW5aYSqUf8V4f70Z-d5fUuuUXnpw@mail.gmail.com>
	<1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jw@nuclearfallout.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbbCLDvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:51:36 -0400
In-Reply-To: <1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Mar 2015 18:42:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> John reported that my previous commit added a regression
> on his router.
> 
> This is because sender_cpu & napi_id share a common location,
> so get_xps_queue() can see garbage and perform an out of bound access.
> 
> We need to make sure sender_cpu is cleared before doing the transmit,
> otherwise any NIC busy poll enabled (skb_mark_napi_id()) can trigger
> this bug.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: John <jw@nuclearfallout.net>
> Bisected-by: John <jw@nuclearfallout.net>
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")

Applied, thanks Eric.
