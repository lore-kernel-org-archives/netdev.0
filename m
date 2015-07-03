From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Fri, 03 Jul 2015 09:37:15 -0700 (PDT)
Message-ID: <20150703.093715.1504840554531952050.davem@davemloft.net>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
	<1435899623.11970.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brakmo@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbbGCQhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:37:17 -0400
In-Reply-To: <1435899623.11970.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Jul 2015 07:00:23 +0200

> tcp_skb_cb is currently 44 bytes, so even if you add one u32, it should
> not exceed cb[]

Please see sock_skb_cb, which consumes space in skb->cb[] in parallel
with things like tcp_skb_cb.  The usage of skb->cb[] therefore really
is 48 bytes and I'm sure the build time assertions triggered if
Lawrence added the new tcp_skb_cb member without first increasing it's
size.
