From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 silicon bugs and workarounds...
Date: Mon, 2 Jul 2007 08:56:12 -0700
Message-ID: <20070702085612.45eb7aeb@freepuppy.localdomain.hemminger.net>
References: <6278d2220707020636h7764fb27lb648ce50f1597b4@mail.gmail.com>
	<6278d2220707020637m2f11a691x9c51ca4bfe823104@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58936 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753260AbXGBP4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 11:56:45 -0400
In-Reply-To: <6278d2220707020637m2f11a691x9c51ca4bfe823104@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Jul 2007 14:37:06 +0100
"Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> Hi Stephen,
> 
> When the sky2 driver initialises, it sets the the ISR timer register
> (STAT_ISR_TIMER_INI) to 125 * 20 = 2500, whereas the vendor sk98lin
> driver sets it to 400, irrespective of the clockspeed of the NIC
> processor.
> 
> I guess you found more performance/stability from this value...?


Not really, it was just a rough guess to try and get more frames
per irq under DoS load.  Haven't fine tuned those values.

> 
> I've checked through the errata workarounds common to my rev-1 and 2
> Yukon-EC chips...the HWF_WA_DEV_4167 "oversize receive hang"
> workaround checks and can reset the (as I understand) bus master unit
> of the NIC (in CheckRxPath) in a periodic timer that is fired, where
> is finds no progress is made.

Where did you get those errata's. I keep having to do reverse
engineering guessing with vendor driver.

> With the issues we see, can they be detected earlier by the stats
> counters not being incremented, then resetting the bus-master unit,
> rather than the whole chip getting kicked after a far longer period.
> 
> It looks like if it is a silicon bug, we can just acknowledge it and
> have a better framework to detect the chip's PCI interface locking up
> and kick it in a smarter way perhaps...
> 
> Daniel
> --
> Daniel J Blueman


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
