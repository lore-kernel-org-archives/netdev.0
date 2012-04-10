From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 13:50:25 +0200
Message-ID: <1334058625.3126.101.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
	 <1334057529.3126.90.camel@edumazet-glaptop>  <4F841BB9.2030209@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43989 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2DJLua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 07:50:30 -0400
Received: by bkcik5 with SMTP id ik5so4123710bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 04:50:29 -0700 (PDT)
In-Reply-To: <4F841BB9.2030209@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 13:38 +0200, Michal Simek wrote:
> On 04/10/2012 01:32 PM, Eric Dumazet wrote:
> >
> > ll_temac allocates XTE_MAX_JUMBO_FRAME_SIZE frames, even for MTU=1500 ?
> 
> yes.
> 
> >
> > Trying to allocate smaller packets would definitely help your tcp
> > receiver performance and overall reliability  (order-0 allocations
> > instead of order-2)
> 
> There is long history for ll_temac and axi emac drivers. and if you compare
> them they are very similar with similar bugs.
> In our distribution we are using older ll_temac driver where this is fixed.
> Performance is much higher if you allocate buffers for actual mtu.
> 
> Thanks,
> Michal
> 
> P.S.: Our plan is to start to use mainline drivers and fixing them to get
> the same performance as we have with old one. It is one my todo list.

Ah good, because this 9000+pad versus 1500+pad allocation is way more
problematic than the (small) change on skb->truesize you bisected ;)
