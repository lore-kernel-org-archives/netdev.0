From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 22:59:50 +0900 (JST)
Message-ID: <20070712.225950.12335719.noboru.obata.ar@hitachi.com>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
    <20070712.023710.36923635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:33248 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760175AbXGLN7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 09:59:55 -0400
Received: from mlsv15.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id B788C37AE3
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 22:59:53 +0900 (JST)
In-Reply-To: <20070712.023710.36923635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 02:37:10 -0700 (PDT)

> Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
> From: David Miller <davem@davemloft.net>
> To: noboru.obata.ar@hitachi.com
> Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
>    netdev@vger.kernel.org
> Date: 	Thu, 12 Jul 2007 02:37:10 -0700 (PDT)
> X-Mailer: Mew version 5.1.52 on Emacs 21.4 / Mule 5.0 (SAKAKI)
> 
> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> Date: Thu, 12 Jul 2007 16:15:10 +0900 (JST)
> 
> > 1. Network device layer detects a failure first and switch to a
> >    backup device (say, in 20sec).
> > 
> > 2. TCP layer timeout & retransmission comes next, _hopefully_
> >    before the application layer timeout.
> > 
> > 3. Application layer detects a network failure last (by, say,
> >    30sec timeout) and may trigger a system-level failover.
> > 
> >    * Note 1.  The timeouts for #1 and #2 are handled
> >      independently and there is no relationship between them.
> > 
> >    * Note 2.  The actual timeout settings (20sec or 30sec in
> >      this example) are often determined by systems requirement
> >      and so setting them to certain "safe values" (if any) are
> >      usually not possible.
> > 
> > If TCP retransmission misses the time frame between event #1
> > and #3 in Background above (between 20 and 30sec since network
> > failure), a failure causes the system-level failover where the
> > network-device-level failover should be enough.
> 
> I'm still totally unconvinced, this seems pointless.
> 
> TCP's timeouts are perfectly fine, and the only thing you
> might be showing above is that the application timeouts
> are too short or that TCP needs notifications.

I take your comment seriously, David.

And I agree with you that TCP's timeouts are fine on a network
where congestion is a primary reason of packet loss.

But in a high-speed LAN today, for example, congestion is
effectively diminished by network capacity design, and physical
failure of devices and cables is now a major concern, which is
addressed by redundant devices and failover.  TCP's timeouts
(RTT/RTO estimation and exponential backoff) work fine as well
on failover-capable networks, but I think smaller TCP_RTO_MAX is
desirable because failover can be taken place in order of
seconds.  This will surely increase the usefullness of TCP on
such networks.

How do you think TCP timeouts in Linux can adapt to such changes
in network environment?

> I am totally unconvinced about your dom0 vs. domU notification
> arguments as well.

Well, I'd appreciate if you could tell me a bit more in detail
why my argument does not make sense to you.

In a virtualized environment, a failure is detected in Dom-0,
and TCP stack to be notified sits on Dom-U.  I think
notifications from Dom-0 to Dom-U TCP are not easy.

Best regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
