From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: locking api self-test hanging
Date: Tue, 4 Mar 2008 08:40:24 +0000
Message-ID: <20080304084024.GA3980@ff.dom.local>
References: <20080303210540.cea55e13.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:37757 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762845AbYCDIjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 03:39:11 -0500
Received: by ug-out-1314.google.com with SMTP id z38so2541749ugc.16
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 00:39:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080303210540.cea55e13.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-03-2008 06:05, Andrew Morton wrote:
...
>>>> And I've fully bisected this hang twice and both times came up with
>>>>
>>>> commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
>>>> Author: Stephen Hemminger <shemminger@linux-foundation.org>
>>>> Date:   Mon Nov 19 19:24:52 2007 -0800
>>>>
>>>>     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
>>>>
>>>> which is stupid because that patch doesn't do anything.

...or maybe apparently doesn't do anything?

@@ -128,13 +127,11 @@ static int poll_one_napi(struct netpoll_info *npinfo,
        if (!test_bit(NAPI_STATE_SCHED, &napi->state))
                return budget;
 
-       npinfo->rx_flags |= NETPOLL_RX_DROP;


But in a next patch we can see:

@@ -51,12 +50,12 @@ static inline int netpoll_rx(struct sk_buff *skb)
        unsigned long flags;
        int ret = 0;
 
-       if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
+       if (!npinfo || !npinfo->rx_np)

So, it seems rx_flags could have been tested here for NETPOLL_RX_DROP
yet?

Regards,
Jarek P.
