From: David Miller <davem@davemloft.net>
Subject: Re: via-rhine interrupts
Date: Wed, 18 Aug 2010 23:49:39 -0700 (PDT)
Message-ID: <20100818.234939.71574087.davem@davemloft.net>
References: <AANLkTi=xfBSn=FS9=eR=NZa9QwrHAQwGc7Kh1-bUn3aj@mail.gmail.com>
	<20100815200431.GA4993@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ruzicka.jakub@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0HSGtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:49:20 -0400
In-Reply-To: <20100815200431.GA4993@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 15 Aug 2010 22:04:31 +0200

> I've just tested it using a simplistic patch below, which skips
> some napi receiving by doing it only every second jiffie (on even
> ones), and I've got around 30% less interrupts from via-rhine,
> which seems to suggest napi works OK, but there is too low
> traffic (or too fast soft interrupt handling) to affect hard
> interrupts. (Btw, probably CONFIG_HZ can matter here a bit too.
> I tested with 1000.)

100Mbit on any modern system isn't going to trigger NAPI much at all
even with near full link utilization.

The simply cpu processes the packets too fast for them to gather up
much at all.

Some improvement in polling could be gained if the via-rhine has some
HW interrupt mitigation settings.  However after a quick perusal of
the driver I don't see anything about this.  The mitigation ethtool
ops aren't implemented either, so I'm not optimistic :-)



