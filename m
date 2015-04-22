From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix possible deadlock in tcp_send_fin()
Date: Wed, 22 Apr 2015 11:39:27 -0700
Message-ID: <1429727967.18561.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55110009.4020706@akamai.com>
	 <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150422.141534.1363191163633903371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	gthelen@google.com, rientjes@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36295 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbbDVSj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:39:29 -0400
Received: by igblo3 with SMTP id lo3so4275171igb.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 11:39:29 -0700 (PDT)
In-Reply-To: <20150422.141534.1363191163633903371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-22 at 14:15 -0400, David Miller wrote:

> Wrt. longer term solutions, I would even be OK at this point aborting
> the connection altogether if the skb allocation fails period.  Not
> just if TIF_MEMDIE is set.  That endless loop has been nothing but
> trouble.

Agreed.

Note that in the unlikely case skb can not be allocated,
if an already transmitted packet is in the write queue, we also can OR
the FIN flag on it, and rely on normal rtx to deliver this FIN later.

I'll cook a patch when net-next reopens.

Thanks David.
