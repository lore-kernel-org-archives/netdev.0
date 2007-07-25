From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [-mm patch] one e1000 driver should be enough for everyone
Date: Wed, 25 Jul 2007 16:46:16 +0200
Message-ID: <20070725144615.GC3572@stusta.de>
References: <20070725040304.111550f4.akpm@linux-foundation.org> <20070725133650.GB3572@stusta.de> <46A754C7.9080004@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:44037 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755056AbXGYOqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 10:46:43 -0400
Content-Disposition: inline
In-Reply-To: <46A754C7.9080004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 25, 2007 at 09:48:55AM -0400, Jeff Garzik wrote:
> Adrian Bunk wrote:
>> BTW:
>> Unless I'm misunderstanding anything, the new driver should support a 
>> superset of what the old driver supported.
>> Therefore, it would be good if the final merge into Linus' tree will
>> do an
>>   rm -r drivers/net/e1000
>>   mv drivers/net/e1000new drivers/net/e1000
>
> Based on the most recent discussion, e1000new (or whatever it will be 
> called) should support only the newer PCI-Express chips, while e1000 will 
> retain support for the older chips.

I found the discussion, and Christoph's e1000e sounds like the best name 
("new" doesn't say whether it's a new driver for old hardware or a 
driver for new hardware).

> Over the long term this will allow e1000new to grow without affecting 
> support for the older, stable chips.
>
> So, e1000 is not going away.

No problem for me, but this obviously implies that global code in the 
new driver has to be renamed.

And please ensure that they will always support distinct PCI IDs, or 
there will be the following common pattern if both drivers support
a card:
- user tries driver A
- driver A doesn't work (although it should have worked)
- user tries driver B
- driver B works
- a later kernel removes support for this card from driver B
- user tries driver A
- driver A still doesn't work
- user writes bug report

Users should report bugs early instead of bouncing between different 
drivers.

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

