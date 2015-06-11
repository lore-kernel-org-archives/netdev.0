From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: tcp: dctcp_update_alpha() fixes.
Date: Wed, 10 Jun 2015 23:28:49 -0700 (PDT)
Message-ID: <20150610.232849.1817792758322372959.davem@davemloft.net>
References: <1433999477.27504.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbFKG3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:29:05 -0400
In-Reply-To: <1433999477.27504.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Jun 2015 22:11:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> dctcp_alpha can be read by from dctcp_get_info() without
> synchro, so use WRITE_ONCE() to prevent compiler from using
> dctcp_alpha as a temporary variable.
> 
> Also, playing with small dctcp_shift_g (like 1), can expose
> an overflow with 32bit values shifted 9 times before divide.
> 
> Use an u64 field to avoid this problem, and perform the divide
> only if acked_bytes_ecn is not zero.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, applied, thanks Eric.
