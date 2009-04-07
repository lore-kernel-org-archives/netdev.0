From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: 2.6.29 on MacBook 2,
 1 fails to reboot (was Re: 2.6.29-git13: Reported regressions from
 2.6.28)
Date: Tue, 07 Apr 2009 19:10:33 +0200
Message-ID: <49DB8909.3000905@s5r6.in-berlin.de>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>	
	<alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>	
	<49DB7C77.1000702@s5r6.in-berlin.de>
	<9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Takashi Iwai <tiwai@suse.de>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: "Trenton D. Adams" <trenton.d.adams@gmail.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Trenton D. Adams wrote:
> On Tue, Apr 7, 2009 at 10:16 AM, Stefan Richter
> <stefanr@s5r6.in-berlin.de> wrote:
>> Linus Torvalds wrote:
>>> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>>>> Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=13018
>>>> Subject              : 2.6.29 on MacBook 2,1 fails to reboot
...
>>> The bug _sounds_ like some deadlock due to lock problems - the shutdown 
>>> path often triggers locks that no other path really cares about. And we 
>>> had some lock problems in the sound subsystem that got fixed post-2.6.28, 
>>> for example. 
>>> 
>>> And it looks like the problem is somewhere in sound shutdown:
>>> 
>>> 12181 delete_module("snd_hda_codec", O_RDONLY|O_EXCL) = -1 EAGAIN (Resource temporarily unavailable) <0.000011>
>>> 
>>> So commits like 91054598f794fb5d8a0b1e747ff8e2e8fc2115b3 ("ALSA: pcm_oss, 
>>> fix locking typo") might explain it.
...
>> could it be the same as this one?
>> http://bugzilla.kernel.org/show_bug.cgi?id=12321
>> "System hangs when unloading alsa modules"
>> http://bugs.gentoo.org/show_bug.cgi?id=253535
>> "System hangs when unloading alsa modules on Kernel >2.6.28"
...
> The first one looks similar, if not identical.  The second one
> doesn't, because my problem happens on 2.6.29 only, not 2.6.28.

The Gentoo bug entry too is about a regression _after_ 2.6.28. :-)
I.e. 2.6.28.y. are unaffected.  It's actually just the downstream
duplicate of the kernel.org bug entry.

> Either way, the unload problem with the module didn't happen in
> 2.6.28.

Interdependencies between ALSA modules have changed.  The Gentoo init
scripts attempted to unload them in an order which deadlocked modprobe
due to dependencies.  The fix for Gentoo is to just not unload the
modules on system shutdown.  My Gentoo/amd64 Mac mini was affected by
this too; fixed by userland update.

(Added Cc to tiwai@suse.de)
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/
