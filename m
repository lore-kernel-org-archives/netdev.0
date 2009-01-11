From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.29-rc1: Reported regressions from 2.6.28
Date: Sun, 11 Jan 2009 14:47:58 +0100
Message-ID: <20090111134758.GA18299@elte.hu>
References: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43585 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506AbZAKNsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 08:48:53 -0500
Content-Disposition: inline
In-Reply-To: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Rafael J. Wysocki <rjw@sisk.pl> wrote:

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12420
> Subject		: WARNING: at drivers/ata/libata-sff.c:1017 ata_sff_hsm_move+0x45e/0x750()
> Submitter	: Christian Borntraeger <borntraeger@de.ibm.com>
> Date		: 2009-01-09 12:34 (3 days old)
> First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=871af1210f13966ab911ed2166e4ab2ce775b99d
> References	: http://marc.info/?l=linux-kernel&m=123150457832109&w=4

I can trigger it too and it is pretty much resolved - false positive 
WARN_ON() triggered by new (but correct) libata usage.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12417
> Subject		: glx performance drop with: "x86: PAT: implement track/untrack of pfnmap regions for x86 - v3"
> Submitter	: Alexey Fisher <bug-track@fisher-privat.net>
> Date		: 2009-01-06 18:46 (6 days old)
> First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5899329b19100c0b82dc78e9b21ed8b920c9ffb3
> References	: http://marc.info/?l=linux-kernel&m=123126782822696&w=4
> Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>

Should be solved by Venki's PAT fixes in tip/x86/urgent:

 0e95c19: x86, pat: fix reserve_memtype() for legacy 1MB range
 74edd61: x86 PAT: remove CPA WARN_ON for zero pte
 e722dc8: x86 PAT: ioremap_wc should take resource_size_t parameter
 b61e53c: x86 PAT: return compatible mapping to remap_pfn_range callers
 e104ba3: x86 PAT: change track_pfn_vma_new to take pgprot_t pointer param
 3cedb0d: x86 PAT: consolidate old memtype new memtype check into a function
 e61304a: x86 PAT: remove PFNMAP type on track_pfn_vma_new() error

Soon to be sent to Linus.

	Ingo
