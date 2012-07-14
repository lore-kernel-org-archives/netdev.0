From: David Miller <davem@davemloft.net>
Subject: Re: Crash in CIPSO_V4_TAG_LOCAL handling
Date: Sat, 14 Jul 2012 13:08:17 -0700 (PDT)
Message-ID: <20120714.130817.394766887121758073.davem@davemloft.net>
References: <1342286550.23395.12.camel@monkey32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, paul.moore@hp.com, netdev@vger.kernel.org
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2GNUIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 16:08:18 -0400
In-Reply-To: <1342286550.23395.12.camel@monkey32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Sun, 15 Jul 2012 01:22:30 +0800

> It's caused by below code added in commit 15c45f7b.
> 
>                 case CIPSO_V4_TAG_LOCAL:
>                         /* This is a non-standard tag that we only allow for
>                          * local connections, so if the incoming interface is
>                          * not the loopback device drop the packet. */
>                         if (!(skb->dev->flags & IFF_LOOPBACK)) {
>                                 err_offset = opt_iter;
>                                 goto validate_return_locked;
>                         }

Paul please fix this, as shown 'skb' can easily be NULL in this
code path.
