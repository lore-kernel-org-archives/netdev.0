From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Tue, 07 Apr 2009 18:16:55 +0200
Message-ID: <49DB7C77.1000702@s5r6.in-berlin.de>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera> <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Trenton Adams <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.0904061443000.7443-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13018
>> Subject		: 2.6.29 on MacBook 2,1 fails to reboot
>> Submitter	: Trenton Adams <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date		: 2009-03-30 2:04 (8 days old)
>> References	: http://marc.info/?l=linux-kernel&m=123837870307249&w=4
>> Handled-By	: "Morten P.D. Stevens" <mstevens-APqb+XXLJz/QQQFqJy/XgFaTQe2KTcn/@public.gmane.org>
> 
> This went through bisection, but looking at the email log, I tend to 
> suspect that maybe Trenton marked some versions good even though they 
> weren't (because they got versions numbers from v2.6.27), and didn't 
> realize that that messes up bisection in a big way.
> 
> The bug _sounds_ like some deadlock due to lock problems - the shutdown 
> path often triggers locks that no other path really cares about. And we 
> had some lock problems in the sound subsystem that got fixed post-2.6.28, 
> for example. 
> 
> And it looks like the problem is somewhere in sound shutdown:
> 
> 12181 delete_module("snd_hda_codec", O_RDONLY|O_EXCL) = -1 EAGAIN (Resource temporarily unavailable) <0.000011>
> 
> So commits like 91054598f794fb5d8a0b1e747ff8e2e8fc2115b3 ("ALSA: pcm_oss, 
> fix locking typo") might explain it.

Trenton,
could it be the same as this one?
http://bugzilla.kernel.org/show_bug.cgi?id=12321
"System hangs when unloading alsa modules"
http://bugs.gentoo.org/show_bug.cgi?id=253535
"System hangs when unloading alsa modules on Kernel >2.6.28"
-- 
Stefan Richter
-=====-==--= -=-- --===
http://arcgraph.de/sr/
