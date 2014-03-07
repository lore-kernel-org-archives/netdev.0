From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Fri, 07 Mar 2014 08:01:05 -0800
Message-ID: <1394208065.20149.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140305.205938.287751582220842351.davem@davemloft.net>
	 <1394071601.27473.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140305.211530.2206817902037251680.davem@davemloft.net>
	 <1394072451.27473.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <771471B8871B5044A6CA7CCD9C26EEE10117E265CE84@xmail2.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Persson <lars.persson@axis.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:37066 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaCGQBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 11:01:08 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so4223736pde.1
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 08:01:07 -0800 (PST)
In-Reply-To: <771471B8871B5044A6CA7CCD9C26EEE10117E265CE84@xmail2.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-07 at 16:45 +0100, Lars Persson wrote:
> So far no deadlock on the socket lock is seen with this patch. I have seen two out-of-memory crashes which leaves the system deadlocked trying to allocate memory.
> 
> Stack traces and kernel log from one of the oom crashes is attached. I was thinking this may be caused by having the dirty_ratio set too high given our product's heavy use of memory. Currently re-testing with dirty_ratio reduced to 5%.
> 
> 
> [11515.530000] Recording maint invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
> [11515.540000] CPU: 0 PID: 1304 Comm: Recording maint Tainted: G           O 3.10.32 #10
> [11515.550000] Stack : 80666e52 00000049 80660000 00000000 805563dc 8b1876f8 8054af80 805d2227
> 	  00000518 00000000 80656d40 8b1876f8 000007ce 00000002 00000000 8047d858
> 	  00000000 8003bb64 00000006 00000000 8054d024
>  [11515.580000]  8b189a84 8b189a84 8054af80
> 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> 	  00000000 00000000 00000000 00000000 00000000 00000000 00000000 8b189a18
> 	  ...


Well, this is 3.10.32, with local changes to dirty_ratio....

so I will simply ignore mm issues for the moment.

Thanks a lot Lars

Tested-by: Lars Persson <lars.persson@axis.com>
