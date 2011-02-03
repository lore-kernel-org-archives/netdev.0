From: Jesper Juhl <jj@chaosbits.net>
Subject: potential null pointer dereference in drivers/isdn/hisax/isdnl2.c
Date: Thu, 3 Feb 2011 21:27:56 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102032121180.15101@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:11076 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab1BCU2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 15:28:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In drivers/isdn/hisax/isdnl2.c:l2_pull_iqueue() we have this:

	...
		skb = alloc_skb(oskb->len + i, GFP_ATOMIC);
		memcpy(skb_put(skb, i), header, i);
	...

If alloc_skb() fails and returns NULL then the second line will cause a 
NULL pointer dereference - skb_put() gives the pointer to 
skb_tail_pointer() which dereferences it.

I'm not quite sure how this should be dealt with, so I'll just report it 
rather than submit a patch. Happy bug fixing :-)


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

