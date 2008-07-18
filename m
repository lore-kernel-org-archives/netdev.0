From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Fri, 18 Jul 2008 00:12:02 -0700 (PDT)
Message-ID: <20080718.001202.193698926.davem@davemloft.net>
References: <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
	<20080717.190315.186892939.davem@davemloft.net>
	<19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752697AbYGRHME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 03:12:04 -0400
In-Reply-To: <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vegard Nossum" <vegard.nossum@gmail.com>
Date: Fri, 18 Jul 2008 09:03:50 +0200

> > It's supposed to be 0x6b, this would be a "--"
> 
> You're right! Oops. In my defence, I wrote that at 2 AM last night ;-)
> 
> > Also it (more likely IMHO) could be clearing a flag with the value 0x01.
> 
> It could be. But like I said in a later e-mail, the thing is likely
> sk_buff->truesize. Which is not a flags variable. It _is_ however, a
> counter, which is frequently -= and atomic_sub()ed.

skb->truesize is ever incremented or decremented by only one.

Usually it is changed by the entire packet size, or at least one MSS's
worth.

On packet free, it will be decremented by at least sizeof(struct sk_buff)
