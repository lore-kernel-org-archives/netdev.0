From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to protect
 flash memory
Date: Wed, 24 Sep 2008 01:45:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0809240142030.27884@twin.jikos.cz>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
 <20080923.162957.141669474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:42154 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbYIWXqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 19:46:51 -0400
In-Reply-To: <20080923.162957.141669474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008, David Miller wrote:

> > A number of users have reported NVM corruption on various ICHx platform
> > LOMs.  One possible reasons for this could be unexpected and/or malicious
> > writes to the flash memory area mapped into kernel memory.  Once the
> > interface is up, there should be very few reads/writes of the mapped flash
> > memory.  This patch makes use of the x86 set_memory_*() functions to set
> > the mapped memory read-only and temporarily set it writable only when the
> > driver needs to write to it.  With the memory set read-only, any unexpected
> > write will be logged with a stack dump indicating the offending code.
> > Since these LOMs are only on x86 ICHx platforms, it does not matter that
> > this API is not yet available on other architectures, however it is
> > dependent on a previous patch that exports these function name symbols.
> If the X server or similar is causing this problem, this patch won't 
> help. The X server maps MMIO space using mmap() in userspace, and you're 
> only protecting the kernel side mapping.

Yes, probably not a vanilla kernel material, but could be very well used 
for testing to further isolate whether it is kernel or userspace 
corrupting the memory mapped eeprom.

At least I will build suse kernel package with these patches applied and 
ask users who are able to reproduce the problem and willing to test (if 
there are any that have backported their EEPROM properly before running 
new kernel :) ) to give it a try.

-- 
Jiri Kosina
SUSE Labs

