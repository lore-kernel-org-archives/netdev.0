From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 15:37:36 +0100
Message-ID: <1215182256.10393.805.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org>  <20080704143058.GB23215@mit.edu>
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
Received: from bombadil.infradead.org ([18.85.46.34]:33385 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154AbYGDOiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 10:38:02 -0400
In-Reply-To: <20080704143058.GB23215@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 10:30 -0400, Theodore Tso wrote:
> HOWEVER, as I mentioned in another message, it looks like not all
> forms of mkinitd and/or mkinitramfs scripts deal with /lib/firmware
> correctly, including the one used by the latest version of Ubuntu.
> That to me is a strong argument for either (a) leaving drivers the way
> they are now, or (b) making the new request_firmware() framework be
> able to place the firemware in either the original driver module, or
> in another tg3_firmware.ko module --- which could be unloaded
> afterwards, if people really cared about the non-swappable kernel
> memory being used up.)

Yeah. I had checked that Ubuntu and Fedora _do_ cope with including
firmware in the kernel, but wasn't expecting that Ubuntu would then go
screw it up.

As I said, it's not _impossible_ to include firmware directly in the
module itself; it should just be a case of adding an additional section
like it was in the kernel too, and handling some lifetime issues.

If Ubuntu (and SuSE) are currently shipping broken initramfs tools, then
that may tip the balance from that being unnecessary complexity to
something we should probably do for the short term. Even though they're
_already_ broken, and we're only really taking it from "broken for 70
drivers in initramfs" to "broken for 90 drivers in initramfs". Or
whatever the numbers are. Admittedly I just made those ones up.

> And this is where we pay the price for not having a standard initrd
> generation (with appropriate hooks so that distros could drop in their
> own enhancements) as part of the kernel build process.  If we did, it
> would be a lot easier to make sure all distro's learn about new
> requirements that we have imposed on the initrd.  Because we haven't,
> initrd's are effectively part of the "exported interface" where we
> have to move slowly enough so that distro's can catch up depending on
> their release schedule.  (It also makes it much harder to run a
> bleeding-edge kernel on a release distro system, at least without
> tieing our hands with respect to changes involving the initrd.)

Yeah, you're probably right.

-- 
dwmw2

