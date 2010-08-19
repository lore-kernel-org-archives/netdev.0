From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: via-rhine interrupts
Date: Thu, 19 Aug 2010 19:09:12 +0200
Message-ID: <20100819170912.GA2387@del.dom.local>
References: <AANLkTi=xfBSn=FS9=eR=NZa9QwrHAQwGc7Kh1-bUn3aj@mail.gmail.com>
 <20100815200431.GA4993@del.dom.local>
 <20100818.234939.71574087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ruzicka.jakub@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45812 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391Ab0HSRJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 13:09:24 -0400
Received: by bwz11 with SMTP id 11so1366950bwz.19
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 10:09:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100818.234939.71574087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 11:49:39PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 15 Aug 2010 22:04:31 +0200
> 
> > I've just tested it using a simplistic patch below, which skips
> > some napi receiving by doing it only every second jiffie (on even
> > ones), and I've got around 30% less interrupts from via-rhine,
> > which seems to suggest napi works OK, but there is too low
> > traffic (or too fast soft interrupt handling) to affect hard
> > interrupts. (Btw, probably CONFIG_HZ can matter here a bit too.
> > I tested with 1000.)
> 
> 100Mbit on any modern system isn't going to trigger NAPI much at all
> even with near full link utilization.
> 
> The simply cpu processes the packets too fast for them to gather up
> much at all.
> 
> Some improvement in polling could be gained if the via-rhine has some
> HW interrupt mitigation settings.  However after a quick perusal of
> the driver I don't see anything about this.  The mitigation ethtool
> ops aren't implemented either, so I'm not optimistic :-)
> 

Yes, now I see the old comments (pre 2.6.27) mentioned 10kpps
threshold, which wasn't reached in Jakub's example.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=32b0f53e5bc80b87fd20d4d78a0e0cb602c9157a

Jarek P.
