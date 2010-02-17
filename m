From: David Miller <davem@davemloft.net>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 13:42:17 -0800 (PST)
Message-ID: <20100217.134217.244120118.davem@davemloft.net>
References: <20100217191718.GA5256@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754848Ab0BQVmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:42:02 -0500
In-Reply-To: <20100217191718.GA5256@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 17 Feb 2010 21:17:19 +0200

> commit 19f4c7133fc1b94001b997c4843d0a9192ee63e5
> xfrm: Flushing empty SAD generates false events
> 
> commit 0dca3a843632c2fbb6e358734fb08fc23e800f50
> xfrm: Flushing empty SPD generates false events
> 
> setkey now takes several seconds to run this simple script
> and it spits "recv: Resource temporarily unavailable" messages.
> 
> #!/usr/sbin/setkey -f
> flush;
> spdflush;
> 
> add A B ipcomp 44 -m tunnel -C deflate;
> add B A ipcomp 45 -m tunnel -C deflate;
> 
> spdadd A B any -P in ipsec
>         ipcomp/tunnel/192.168.1.2-192.168.1.3/use;
> spdadd B A any -P out ipsec
>         ipcomp/tunnel/192.168.1.3-192.168.1.2/use;

Thanks for the report Alexey.  I'll revert these changes
for now.

Jamal, if you can find a way to do this without breaking
existing applications feel free to send a new version of
these patches.

Thanks.
