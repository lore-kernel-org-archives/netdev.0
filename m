From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Mon, 1 Feb 2010 10:47:22 +0000
Message-ID: <20100201104722.GA12329@ff.dom.local>
References: <4B6216B9.1010802@majjas.com> <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com> <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com> <4B65D0F9.2020602@majjas.com> <4B65FD12.7090101@majjas.com> <20100131221835.GA3317@del.dom.local> <4B661E22.8090907@majjas.com> <4B6657DB.3010008@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:57043 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225Ab0BAKrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 05:47:31 -0500
Content-Disposition: inline
In-Reply-To: <4B6657DB.3010008@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 31, 2010 at 11:26:03PM -0500, Michael Breuer wrote:
> FYI - tried generating lots of extra tx traffic... found a way to  
> generate the rx status messages on demand:
>     ping -i .0000001 -s 8000 -t 2 <host> >/dev/null
>
> Yields:
> Jan 31 23:08:07 mail kernel: sky2 eth0: rx error, status 0x1f6a0010  
> length 1518
...
> Jan 31 23:08:12 mail kernel: net_ratelimit: 316 callbacks suppressed
> etc.
...
> Understanding that the other side is out of spec, I'd still wonder why  
> the sky2 driver generates rx errors. Perhaps overruns should be tossed  
> silently... by the hardware if possible.

Of course it's a matter of taste, but it seems such errors shouldn't
be tolerated in a local network. I'd rather prefer doing them more
explicit (like e.g. some other kind of length errors).

Jarek P.
