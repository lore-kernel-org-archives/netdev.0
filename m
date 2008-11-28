From: Ingo Molnar <mingo@elte.hu>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 09:34:15 +0100
Message-ID: <20081128083415.GA1131@elte.hu>
References: <492DD792.6080302@linux.intel.com> <20081127115236.GE29013@elte.hu> <492EE087.80708@linux.intel.com> <20081127201836.GA16869@elte.hu> <20081127122800.45fc0b1a@linux.intel.com> <20081127204714.GA25875@elte.hu> <20081127125301.3cb1e282@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>,
	"H. Peter Anvin" <hpa@zytor.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49851 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328AbYK1Iey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 03:34:54 -0500
Content-Disposition: inline
In-Reply-To: <20081127125301.3cb1e282@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> On Thu, 27 Nov 2008 21:47:14 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > IIRC the problem is that vmware _does_ claim that it supports MTRRs. 
> 
> it might.
> but even if they would fix that, we would still WARN (
> at least we should do our side correctly...

As pointed out in other parts of the thread, that is not the case.

Anyway, as i said it in the onset, if you think we should remove the 
warning altogether, or tweak it, we can do that - it is important to 
have relevant warnings show up in kerneloops.org.

To sum it up: the only remaining MTRR warnings we know of are either:

 1) apparently genuine BIOS bugs that do cause problems if the (new) 
    kernel does not fix them up.

    The MTRR warning is relevant and correct in those cases.

or:

 2) sucky virtualization solutions that cheat the guest OS by faking 
    "MTRR support" in the CPUID info, but not actually showing any 
    MTRRs. These virtualization solutions do not even properly 
    identify themselves to the kernel.

    The MTRR warning is unnecessary in this case.

So what we did in the x86 tree was remove the warning in the second 
case - is to properly identify vmware (and in general, virtualization) 
guests.

It was not a simple oneliner:

 earth4:~/tip> gll linus..x86/detect-hyper

 4e42ebd: x86: hypervisor - fix sparse warnings
 c450d78: x86: vmware - fix sparse warnings
 fd8cd7e: x86: vmware: look for DMI string in the product serial key
 6bdbfe9: x86: VMware: Fix vmware_get_tsc code
 395628e: x86: Skip verification by the watchdog for TSC clocksource.
 eca0cd0: x86: Add a synthetic TSC_RELIABLE feature bit.
 88b094f: x86: Hypervisor detection and get tsc_freq from hypervisor
 49ab56a: x86: add X86_FEATURE_HYPERVISOR feature bit
 b2bcc7b: x86: add a synthetic TSC_RELIABLE feature bit

and it will benefit vmware guests in many more areas than just a 
sharper MTRR warning message. That code is queued up for v2.6.29.

	Ingo
