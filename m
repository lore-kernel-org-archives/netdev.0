From: Willy Tarreau <w@1wt.eu>
Subject: GRO + splice panics in 3.7.0-rc5
Date: Thu, 15 Nov 2012 23:28:12 +0100
Message-ID: <20121115222812.GA647@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:35780 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab2KOW2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 17:28:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was just about to make a quick comparison between LRO and GRO in
3.7.0-rc5 to see if LRO still had the big advantage I've always observed,
but I failed the test because as soon as I enable LRO + splice, the kernel
panics and reboots.

I could not yet manage to catch the panic output, I could just reliably
reproduce it, it crashes instantly.

All I can say at the moment is the following :
  - test consist in forwarding HTTP traffic between two NICs via haproxy
  - driver used was myri10ge
  - LRO + recv+send : OK
  - LRO + splice : OK
  - GRO + recv+send : OK
  - GRO + splice : panic
  - no such problem was observed in 3.6.6 so I think this is a recent
    regression.

I'll go back digging for more information, but as I'm used to often see
Eric suggest the right candidates for reverting, I wanted to report the
issue here in case there are easy ones to try first.

Thanks,
Willy
