From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 14:27:15 +0100
Message-ID: <1215178035.10393.763.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, tytso@mit.edu,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37612 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191AbYGDN1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:27:34 -0400
In-Reply-To: <486E2260.5050503@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 09:15 -0400, Jeff Garzik wrote:
> 
> However, there is still a broken element to the system:  the firmware no 
> longer rides along in the module's .ko file.  That introduces new 
> problems for any user and script that copies modules around.
> 
> The compiled-in firmware should be in the same place where it was before 
> your changes -- in the driver's kernel module.

No, Jeff. That is neither new, nor a real problem. You're just
posturing.

That's the way it has been for a _long_ time anyway, for any modern
driver which uses request_firmware(). The whole point about modules is
_modularity_. Yes, that means that sometimes they depend on _other_
modules, or on firmware. 

The scripts which handle that kind of thing have handled inter-module
dependencies, and MODULE_FIRMWARE(), for a long time now.

If I ask mkinitrd to include the b43 driver in my initrd, for example,
it should quite happily include both mac80211.ko and the required
firmware.

All I'm doing is updating some of the older drivers which don't conform
to current best practice, and which still keep large chunks of data in
unswappable kernel memory instead of loading it on demand. And making
that more workable in the general case, but giving the _option_ of
building arbitrary firmware into the kernel, for _all_ modern drivers.

Your argument makes about as much sense as an argument that we should
link b43.ko with mac80211.ko so that the 802.11 core code "rides along
in the module's .ko file". It's just silly.

-- 
dwmw2

