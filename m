From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] get rid of unused revision element
Date: Mon, 14 Jan 2008 04:06:57 -0800 (PST)
Message-ID: <20080114.040657.117757802.davem@davemloft.net>
References: <20080112064646.132747871@linux-foundation.org>
	<20080112.205059.223738374.davem@davemloft.net>
	<18315.19232.437801.553809@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754071AbYANMHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 07:07:05 -0500
In-Reply-To: <18315.19232.437801.553809@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Mon, 14 Jan 2008 12:44:32 +0100

>  The idea was to have a selective flush of route cache entries when
>  a fib insert/delete happened. From what I remember you added another/
>  better solution. Just a list with route cache entries pointing to parent 
>  route. So yes this was obsoleted by your/our effort to avoid total 
>  flushing of the route cache. Unfinished work.

Yes, that's right.  The synchronization was very hard.

But there is another issue, see below....

>  According to  http://bgpupdates.potaroo.net/instability/bgpupd.html
>  (last in page) we currently flush the route cache 2.80 times per second. 
>  when using full Internet routing with Linux. Maybe we're forced to pick 
>  up this thread again someday.

This proves we need to solve this problem.

The reason I've never gone back to that work is that I didn't
want to do it while we still had multiple FIB data structure
implementations.

Someone needs to go over whatever deficiencies exist in fib_trie
vs. fib_hash so that we can delete fib_hash and move over to using
fib_trie always.  It makes no sense to implement everything
interfacing into that code twice.

There was a full consensus that this was the way to move forward,
we just need the dirty work to be done.

If someone wants to show their gratitude for my getting rid of
the multipath cached routing code, the above work would be a
great way to do so (hint hint) :-)
