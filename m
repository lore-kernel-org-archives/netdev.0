From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tg3: Fix for tg3 transmit queue 0 timed
 out when too many gso_segs.
Date: Wed, 20 Jan 2016 20:36:54 -0800
Message-ID: <1453351014.1223.353.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
	 <1453290418-15331-3-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, mchan@broadcom.com,
	prashant@broadcom.com
To: skallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34544 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbcAUEjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 23:39:07 -0500
Received: by mail-pa0-f46.google.com with SMTP id uo6so16728430pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 20:39:06 -0800 (PST)
In-Reply-To: <1453290418-15331-3-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 17:16 +0530, skallam wrote:
> From: Siva Reddy Kallam <siva.kallam@broadcom.com>
> 
> There is an issue on the GSO path inside tg3_tso_bug() when we don't
> have sufficient descriptors available, we stop the queue. This queue
> may never get started again as there are no Tx completions pending.
> 
> For example if the tcp segment size is as low as 88 bytes and TSO packet
> from the stack is quite big(<64 K), gso_segs exceeds the limit of
> descriptors available.
> 
> tg3_tso_bug_gso_check() is implemented to verify if the total no. of
> descriptors available for gso are sufficient or not. If not sufficient
> we simply linearize the the skb and transmit it once again or drop the
> skb.

I find this changelog misleading.

linearize wont change gso_segs

You are in fact segmenting the GSO packet, which is very different than
linearizing it.
