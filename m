From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Thu, 28 Aug 2008 02:46:17 -0700 (PDT)
Message-ID: <20080828.024617.117112334.davem@davemloft.net>
References: <48B44768.3030208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lachlan.andrew@gmail.com
To: virtualphtn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbYH1JqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 05:46:22 -0400
In-Reply-To: <48B44768.3030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Quetchenbach <virtualphtn@gmail.com>
Date: Tue, 26 Aug 2008 11:11:52 -0700

> I'm trying to use the TCP_MAXSEG option to setsockopt() to set the MSS
> for both sides of a bidirectional connection.
> 
> man tcp says: "If this option is set before connection establishment, it
> also changes the MSS value announced to the other end in the initial
> packet."
> 
> However, the kernel only uses the MTU/route cache to set the advertised
> MSS. That means if I set the MSS to, say, 500 before calling connect(),
> I will send at most 500-byte packets, but I will still receive 1500-byte
> packets in reply.
> 
> This is a bug, either in the kernel or the documentation.

I think this got broken by accident several years ago, shows how many
people use this feature :)

We used to use ->mss_clamp to determine the MSS option value,
but along the way when all of the code using ->advmss et al.
was added it didn't get translated correctly.

Thanks for your patch, I'll mull over this and put in the fix
once I understand exactly how this got broken.
