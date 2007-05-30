From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 21:32:18 +0200
Message-ID: <465DD142.6040409@trash.net>
References: <20070529180112.GC5411@linux-os.sc.intel.com> <20070530105936.6c988da5.akpm@linux-foundation.org> <20070530112056.0aeb9498@freepuppy> <465DC598.5060407@trash.net> <20070530191533.GB3216@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbXE3TdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 15:33:06 -0400
In-Reply-To: <20070530191533.GB3216@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venki Pallipadi wrote:
> On Wed, May 30, 2007 at 08:42:32PM +0200, Patrick McHardy wrote:
> 
>>
>>It seems wasteful to add per-packet overhead for tx timeouts, which
>>should be an exception. Do drivers really care about the exact
>>timeout value? Compared to a packet transmission time its incredibly
>>long anyways ..
> 
> 
> I agree. Doing a mod_timer or hrtimer_forward to push forward may add to the
> complexity depending on how often TX happens.
> 
> Are the drivers really worried about exact timeouts here?


Just guessing, but I don't think they are, after all timers can be late.

> Can we use rounding for the timers that are more than a second, at least?


Also sounds reasonable.
