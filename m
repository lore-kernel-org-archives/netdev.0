From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 00:41:45 -0700
Message-ID: <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
	<20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>,
	Adam Kropelin <akropel1@rochester.rr.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
	Allen Parker <parker@isohunt.com>, jesse.brandeburg@intel.com,
	gregkh@suse.de, linux-pci@atrey.karlin.mff.cuni.cz,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44950 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946379AbXBCHnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 02:43:07 -0500
In-Reply-To: <45C42669.2010105@intel.com> (Auke Kok's message of "Fri, 02 Feb
	2007 22:06:33 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> writes:

> Adrian Bunk wrote:
>> This email lists some known regressions in 2.6.20-rc7 compared to 2.6.19
>> that are not yet fixed in Linus' tree.
>>
>> If you find your name in the Cc header, you are either submitter of one
>> of the bugs, maintainer of an affectected subsystem or driver, a patch
>> of you caused a breakage or I'm considering you in any other way possibly
>> involved with one or more of these issues.
>
>
>> Subject    : e1000: 82571EB/82572EI PCI-E cards: link is always down
>>              (MSI related)
>> References : http://lkml.org/lkml/2007/1/16/27
>>              http://lkml.org/lkml/2007/1/17/182
>> Submitter  : Allen Parker <parker@isohunt.com>
>>              Adam Kropelin <akropel1@rochester.rr.com>
>> Handled-By : Auke Kok <auke-jan.h.kok@intel.com>
>> Status     : problem is being debugged
>
> I probably can't fix this bug. Not only do I doubt that the e1000 driver is at
> fault here, I don't have a system with this particular chipset. Most likely the
> regression comes from a combination of MSI layer rewrites and possibly platform
> issues. We've seen many reports that are similar and all are on the platform
> type mentioned here. I really don't want to point fingers here either.
>
> None of the MSI code in e1000 has changed significantly either. as far as I can
> see, the msi code in e1000 has not changed since 2.6.18. Nonetheless there's no
> way I can debug any of this without a system.
>
> I will address the fact that we are lacking any of these systems to test on, but
> that is not going to get this issue handled (not to mention soon) in the way it
> needs to be.
>
> I strongly encourage the people on the linux-pci list to help out, I'll trace
> the e1000 driver for suspicious activity (again), but I run countless tests on
> the latest trees and nothing has shown up recently, other than Eric Biederman's
> msi irq reclaim leak fix.
>
> Perhaps Adam can git-bisect this issue? Adam?

Do we have any explanation about the weird /proc/interrupts output?
i.e. Multiple MSI irqs being assigned to the same card?

Does /sbin/ifconfig ethN down ; /sbin/ifconfig ethN up have anything to do
with the duplication in /proc/interrupts?

I can't see any way for a pci device that doesn't support msi-x to be assigned
multiple interrupts simultaneously.

I just skimmed through the code and there hasn't been any significant
generic MSI work since 2.6.19.

Did this device really work with MSI enabled in 2.6.19?

Eric
