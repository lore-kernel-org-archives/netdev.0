From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 15:24:03 -0700
Message-ID: <m1wt2yzxq4.fsf@ebiederm.dsl.xmission.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
	<20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
	<m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
	<089b01c747be$0ca22620$84163e05@kroptech.com>
	<45C4F3F1.6060500@intel.com>
	<093c01c747d6$45f9a2f0$84163e05@kroptech.com>
	<45C4FDF4.4060002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adam Kropelin <akropel1@rochester.rr.com>,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
	Allen Parker <parker@isohunt.com>, jesse.brandeburg@intel.com,
	gregkh@suse.de, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53994 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbXBCWZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 17:25:30 -0500
In-Reply-To: <45C4FDF4.4060002@intel.com> (Auke Kok's message of "Sat, 03 Feb
	2007 13:26:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> writes:

> that's explained by a driver change that did that. Since at initialization we're
> basically waiting for a link change to tell the stack that we're up, we decided
> to change the order to have the hardware fire an LSI interrupt to trigger a
> watchdog run. So no interrupts would immediately explain why the watchdog never
> runs. That's nothing to worry about for this problem, as soon as interrupts are
> seen in /proc/interrupts this all starts working for e1000.


While I think we need to fix this issue, and in general the issue of MSI
interrupts on PCI-Express busses downstream of hypertransport chains.
This e1000 issue is not a regression, so not fixing it for 2.6.20 is
not a big deal.

I have yet to see all of the pieces I'm trying to look at confirmed,
but I believe by at least looking at the hypertransport MSI mapping
capability's enable bit in general we should be able to do a much
better job of detecting if MSI works in a system or not.

I though someone several months ago had made our MSI supported detect logic
a lot smarter, with defaults that were generally correct, but looking
at the kernel that code apparently never made it anywhere.  Instead
all I see are a handful of common chipsets special cased by the quirk logic.

We should be able to do a lot better but not in the 2.6.20 time frame.

As for the original problem report with duplicate MSI interrupts in
/proc/interrupts.  That sounds like a regression and is probably
simple to fix if we can get some more details.

Eric
