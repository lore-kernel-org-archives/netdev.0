From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 15:31:52 +0100
Message-ID: <1215181913.10393.799.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704141014.GA23215@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Theodore Tso <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54598 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbYGDOcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 10:32:17 -0400
In-Reply-To: <20080704141014.GA23215@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 10:10 -0400, Theodore Tso wrote:
> 
> FYI, at least Ubuntu Hardy's initramfs does not seem to deal with
> firmware for modules correctly.  
> 
> https://bugs.launchpad.net/ubuntu/+source/initramfs-tools/+bug/180544
> 
> And remember, kernel/userspace interfaces are things which are far
> more careful about than kernel ABI interfaces....
> 
> You can flame about Ubuntu being broken (and I predict you will :-),

Flaming about it being broken wouldn't help; we _have_ to cope with it. 
Thanks for the reference; I'll keep an eye on it. 

Again, though, this just makes it clear that it's a _already_ a problem
which affects _every_ modern driver that uses request_firmware() -- so
one might reasonably assume it's already quite a high priority for them
to fix. Remember, I'm not doing anything _new_ when I update drivers to
use request_firmware(). That's actually been the norm for new drivers,
like ipw2200, for a _long_ time now.

So I'd kind of expect that by the time Ubuntu gets round to shipping a
2.6.27 kernel, they'd have long since fixed the bug in their scripts.
The few extra drivers which we've updated to conform to best current
practice, in the few cases where people actually need them in the
initrd, should be fairly much in the noise.

But as I said before, maybe there is some sense in leaving the network
drivers for now, and getting on with all the _other_ drivers which need
updating to use request_firmware() first.

> And so adding more breakages when it is *known* the distro's aren't
> moving as quickly as you think is reasonable for quote, modern,
> unquote, drivers is something you can flame about, but at the end of
> the day, *you* are the one introducing changes that is causing more#
> breakages.  

I don't think the Ubuntu bug you reference is because they aren't
"keeping up". AFAICT their tool _does_ look at MODULE_FIRMWARE() and
include the required firmware in the initramfs. But they have decided to
keep firmware in /lib/firmware/`uname -r`/ instead of /lib/firmware/,
and when making that policy change it looks like they forgot to update
that tool to cope. So it's being stored in the wrong place in the
initramfs.

It's purely a local screwup; just a bug. Not because they're being
'slow'. But it's certainly something we should bear in mind. Thanks for
pointing it out.

-- 
dwmw2

