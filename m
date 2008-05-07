From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 07 May 2008 14:18:35 -0700 (PDT)
Message-ID: <20080507.141835.229114942.davem@davemloft.net>
References: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	<20080506.212722.225900091.davem@davemloft.net>
	<d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756898AbYEGVSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:18:41 -0400
In-Reply-To: <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Wed, 7 May 2008 11:36:59 -0700

> No I haven't tested your patch. I tried to understand skb better before
> applying your patch. After I studied bunch of code, I come to the conclusion
> that your patch won't work for me. First it tracks # of clones, which is not
> what I need. E.g., tcpdump will cause host_inflight to be grossly wrong.

We can make sub-clones not count.

Also, we already can distinguish this case, because all SKB clones
made by TCP are fast-clones.  So we could only bump the counter for
fast clones.  If tcpdump clones it again, it won't be a fast clone and
therefore we can avoid bumping the counter in that case.  Similarly
for other features that want to clone.

Please try to get your idea working with my infrastructure.  We
can modify it to behave however you need it to, but at the core
it's the idea that tracks the state most directly and properly.
