From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 silicon bugs and workarounds...
Date: Mon, 2 Jul 2007 09:16:01 -0700
Message-ID: <20070702091601.750e1783@freepuppy.localdomain.hemminger.net>
References: <6278d2220707020636h7764fb27lb648ce50f1597b4@mail.gmail.com>
	<6278d2220707020637m2f11a691x9c51ca4bfe823104@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35155 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751713AbXGBQQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 12:16:34 -0400
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
> 
> I've checked through the errata workarounds common to my rev-1 and 2
> Yukon-EC chips...the HWF_WA_DEV_4167 "oversize receive hang"
> workaround checks and can reset the (as I understand) bus master unit
> of the NIC (in CheckRxPath) in a periodic timer that is fired, where
> is finds no progress is made.

This code in the vendor driver is not acceptable. It causes the device
to continually reset itself in idle state. The sk9lin driver
can not tell the difference between no packets arriving and hung!


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
