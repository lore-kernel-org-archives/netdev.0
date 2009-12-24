From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Thu, 24 Dec 2009 14:27:12 -0800
Message-ID: <20091224142712.1e5c46d2@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B33BE74.3030704@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54452 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755046AbZLXW1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2009 17:27:34 -0500
In-Reply-To: <4B33BE74.3030704@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Dec 2009 14:18:12 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> I'll be the first to admit I don't know much about network drivers... 
> but I am wondering why __free_page(frag->page); is called in 
> skb_put_frags when the fragment length is zero. I don't see why that 
> page pointer wouldn't potentially be reused afterwords.

When using Jumbo frames, the sky2 driver allocates pages to hold
the larger part of the frame. With 9K MTU it will allocate 2 * 4K pages
and then 1K for start of frame. Then if frame is <= 1K it will drop
the extra pages.  Not sure why this broke now, I am not a VM expert.

-- 
