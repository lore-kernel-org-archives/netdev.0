From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 09:32:17 -0800
Message-ID: <20081128093217.3888fb46@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>
	<20081128111827.79b12739@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41802 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYK1RbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 12:31:13 -0500
In-Reply-To: <20081128111827.79b12739@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Nov 2008 11:18:27 -0600
Jay Cliburn <jcliburn@gmail.com> wrote:

> [trimmed the cc list down to netdev only]
> 
> > Rank 12: dev_watchdog(atl1) (oops)
> > 	Reported 56 times (109 total reports)
> > 	This oops was last seen in version 2.6.27.5, and first seen
> > in 2.6.26.6. More info:
> > http://www.kerneloops.org/searchweek.php?search=dev_watchdog(atl1)
> 
> The tx timeout reports at kerneloops.org appear to be happening on a
> startling variety of network drivers (startling to me, anyway): r8169,
> atl1, atl2, sis900, cdc_ether, orinoco_cs, tg3, ne2k-pci, via-rhine,
> 8139too, ath_pci, e1000, gl620a, sky2, hso, fealnx, forcedeth;
> probably others, but I quit looking.

to be specific in counts, the data I have so far is:

 count |           guilty           
-------+----------------------------
  1599 | dev_watchdog(sis900)
  1501 | dev_watchdog(r8169)
   280 | dev_watchdog(via-rhine)
   264 | dev_watchdog(cdc_ether)
   213 | dev_watchdog(usbnet)
   192 | dev_watchdog(8139too)
   164 | dev_watchdog(8390)
   158 | dev_watchdog(via_rhine)
   129 | dev_watchdog(ne2k-pci)
   122 | dev_watchdog(atl1)
   102 | dev_watchdog(atl2)
   101 | dev_watchdog(orinoco)

and then a long tail of sub-100, omitted to keep this mail not too
long; if anyone wants data on his/her driver not in the list, let me
know.

(please don't read too much in the word "guilty"; it's just the name of
the column in the kerneloops.org database used for identifing which
function was the prime suspect of a backtrace)

> 
> Is it correct to assume all these drivers are showing symptoms of the
> poor timeout handling you mentioned in your r8169 comment, or is the
> occasional tx timeout to be expected, and the leaders in this category
> (r8169, sis900, atl1) are the only ones suffering from deficient
> timeout handling?

For me, sis900 and r8169 stand out; if you look at the data in the
table above, both of these are an order of magnitude more frequent than
the rest of the pack. ATL1 isn't doing all that bad in this regard,
although your driver is still a little higher than other popular cards
like tg3, e1000, e1000e etc. (those are all sub-50). 


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
