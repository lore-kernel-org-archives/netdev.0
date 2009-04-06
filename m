From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Mon, 6 Apr 2009 14:53:19 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Trenton Adams <trenton.d.adams@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35549 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761214AbZDFWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 18:00:39 -0400
In-Reply-To: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13019
> Subject		: /proc/<pid>/maps offset output broken in 2.6.29
> Submitter	: "Chris Friesen" <cfriesen@nortel.com>
> Date		: 2009-04-01 23:18 (6 days old)
> References	: http://marc.info/?l=linuxppc-embedded&m=123862902916059&w=4
> Handled-By	: Hugh Dickins <hugh@veritas.com>

I don't think that's a regression, nor really a bug. It looks cosmetic, 
and likely to be fixed, but not really worth worrying about.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13018
> Subject		: 2.6.29 on MacBook 2,1 fails to reboot
> Submitter	: Trenton Adams <trenton.d.adams@gmail.com>
> Date		: 2009-03-30 2:04 (8 days old)
> References	: http://marc.info/?l=linux-kernel&m=123837870307249&w=4
> Handled-By	: "Morten P.D. Stevens" <mstevens@win-professional.com>

This went through bisection, but looking at the email log, I tend to 
suspect that maybe Trenton marked some versions good even though they 
weren't (because they got versions numbers from v2.6.27), and didn't 
realize that that messes up bisection in a big way.

The bug _sounds_ like some deadlock due to lock problems - the shutdown 
path often triggers locks that no other path really cares about. And we 
had some lock problems in the sound subsystem that got fixed post-2.6.28, 
for example. 

And it looks like the problem is somewhere in sound shutdown:

12181 delete_module("snd_hda_codec", O_RDONLY|O_EXCL) = -1 EAGAIN (Resource temporarily unavailable) <0.000011>

So commits like 91054598f794fb5d8a0b1e747ff8e2e8fc2115b3 ("ALSA: pcm_oss, 
fix locking typo") might explain it.

		Linus
