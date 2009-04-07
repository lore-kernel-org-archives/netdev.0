From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: 2.6.29 on MacBook 2,1 fails to reboot (was Re: 2.6.29-git13:
 	Reported regressions from 2.6.28)
Date: Tue, 07 Apr 2009 21:23:13 +0200
Message-ID: <49DBA821.1070408@s5r6.in-berlin.de>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>	 <49DB7C77.1000702@s5r6.in-berlin.de>	 <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>	 <49DB8909.3000905@s5r6.in-berlin.de> <9b1675090904071122k6a53295fwfffc336011edee8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
To: "Trenton D. Adams" <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9b1675090904071122k6a53295fwfffc336011edee8e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Trenton D. Adams wrote:
> On Tue, Apr 7, 2009 at 11:10 AM, Stefan Richter
> <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
>>>> http://bugs.gentoo.org/show_bug.cgi?id=253535
>> Interdependencies between ALSA modules have changed.  The Gentoo init
>> scripts attempted to unload them in an order which deadlocked modprobe
>> due to dependencies.  The fix for Gentoo is to just not unload the
>> modules on system shutdown.  My Gentoo/amd64 Mac mini was affected by
>> this too; fixed by userland update.
>>
> 
> While that is interesting, I am not seeing that problem on my Gentoo
> box (the macbook), which is completely up-to-date.  2.6.28 works, and
> 2.6.29 doesn't.  Same init scripts, different kernels.

Note that the respective update changed /etc/conf.d/alsasound (a local
configuration file) to include
UNLOAD_ON_STOP="no"
KILLPROC_ON_STOP="no"
This change by update is not activated by a mere emerge; one needs to
incorporate that change with dispatch-conf or an equivalent method.
(Or simply edit the file to have these variables set to "no".)

> And sure, I could put a comment on the rmmod, in the init script, but
> IMO that would be a hack around a _bug_.  Which is fine for me.  But,
> is it worth leaving the issue in the kernel?

Is it a kernel issue if a script attempts to unload a busy module, then
fails to proceed?  I wouldn't think so.

But more importantly, is this init scripts related bug really what's
happening at your system?  Or do you actually experience an entirely
different bug?
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/
