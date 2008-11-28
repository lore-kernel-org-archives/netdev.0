From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 10:50:44 -0800
Message-ID: <20081128105044.241d43c0@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>
	<20081128111827.79b12739@osprey.hogchain.net>
	<20081128093217.3888fb46@linux.intel.com>
	<20081128123631.5209d0b8@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47883 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbYK1Sti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 13:49:38 -0500
In-Reply-To: <20081128123631.5209d0b8@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> > ATL1 isn't doing all that bad in this
> > regard, although your driver is still a little higher than other
> > popular cards like tg3, e1000, e1000e etc. 
> 
> ...And that's what troubles me: the L1 chip isn't what I'd
> characterize as "popular" -- it's LOM only, and it's found in only
> about 25 mainboards that I know of (from voluntary user reports) --
> yet its prevalence in the tx timeout list seems to be quickly rising.
> 
> Can you produce a list from your database for me that includes the
> kernel version for each of the 122 reported atl1 dev_watchdog
> warnings? I'd like to see if I can correlate an increase in the
> warnings with a particular change we made.


=> select count(version), version from oopses where guilty='dev_watchdog(atl1)' group by version order by version desc; 
 count |     version     
-------+-----------------
    93 | 2.6.27.5
     6 | 2.6.27.4
     1 | 2.6.27.3
     1 | 2.6.27.2
     1 | 2.6.27-rc9
     1 | 2.6.27-rc7-git1
     1 | 2.6.27-rc7
     1 | 2.6.27-rc6
     6 | 2.6.27-rc3
     7 | 2.6.27
     4 | 2.6.26.6
(11 rows)


or in more detail:

=> select count(full_version), full_version from oopses where \
guilty='dev_watchdog(atl1)' group by full_version order by \
full_version desc;

 count |           full_version            
-------+-----------------------------------
     2 | 2.6.27.5-94.fc10.x86_64
    26 | 2.6.27.5-41.fc9.x86_64
    12 | 2.6.27.5-41.fc9.i686
    15 | 2.6.27.5-37.fc9.x86_64
    19 | 2.6.27.5-37.fc9.i686
    11 | 2.6.27.5-117.fc10.x86_64
     4 | 2.6.27.5-117.fc10.i686
     1 | 2.6.27.5-109.fc10.x86_64
     2 | 2.6.27.5-109.fc10.i686.PAE
     1 | 2.6.27.5-109.fc10.i686
     1 | 2.6.27.4-79.fc10.i686
     1 | 2.6.27.4-68.fc10.x86_64
     3 | 2.6.27.4-68.fc10.i686
     1 | 2.6.27.4-26.fc9.x86_64
     1 | 2.6.27.3-34.rc1.fc10.i686.PAE
     1 | 2.6.27.2-23.rc1.fc10.x86_64
     4 | 2.6.27-wl
     1 | 2.6.27-rc7
     1 | 2.6.27-rc6-wl-AUS32
     6 | 2.6.27-rc3-wl-8KS-UVC
     1 | 2.6.27-7-generic
     1 | 2.6.27-0.398.rc9.fc10.x86_64
     1 | 2.6.27-0.352.rc7.git1.fc10.x86_64
     2 | 2.6.27
     3 | 2.6.26.6-79.fc9.x86_64
     1 | 2.6.26.6-79.fc9.i686
(26 rows)



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
