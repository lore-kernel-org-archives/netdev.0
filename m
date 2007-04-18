From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make dev_kfree_skb_any check if the skb is valid
Date: Wed, 18 Apr 2007 16:27:04 -0700 (PDT)
Message-ID: <20070418.162704.27783526.davem@davemloft.net>
References: <20070418223339.GE13146@hovland.org>
	<20070418.154416.131918019.davem@davemloft.net>
	<20070418231808.GF13146@hovland.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: erik@hovland.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46877
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992984AbXDRX1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 19:27:01 -0400
In-Reply-To: <20070418231808.GF13146@hovland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Erik Hovland <erik@hovland.org>
Date: Wed, 18 Apr 2007 16:18:15 -0700

> Heh, the reason I came up with this patch is that the code in
> drivers/usb/gadget/ether.c at about line 1653 will attempt to allocate
> an skb. If it fails then it uses a goto to jump to line 1672 where it
> will call dev_kfree_skb_any (skb) on a potentially null skb. I put a
> validity check there and sent it off to the USB gadget maintainer. He
> asked me to instead make the dev_kfree_skb_any call more robust and see
> how that went over on the netdev list. Like a lead balloon?

Yep, like a lead baloon.

The USB gadget driver maintainer should accept your patch
to check for NULL in the gadget driver as that is the one
and only case in the entire tree where that can happen and
we're not eating a conditional and a return just for that
one esoteric case.
