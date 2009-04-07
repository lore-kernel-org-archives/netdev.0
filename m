From: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29 on MacBook 2,1 fails to reboot (was Re: 2.6.29-git13:
	Reported regressions from 2.6.28)
Date: Tue, 7 Apr 2009 10:20:37 -0700
Message-ID: <dd18b0c30904071020v4b4090d9o9721f2d892d9739c@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	 <49DB7C77.1000702@s5r6.in-berlin.de>
	 <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
	 <49DB8909.3000905@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trenton D. Adams" <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
To: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49DB8909.3000905-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2009 at 10:10 AM, Stefan Richter
<stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
> Trenton D. Adams wrote:
>> On Tue, Apr 7, 2009 at 10:16 AM, Stefan Richter
>> <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
>>> Linus Torvalds wrote:
>>>> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>>>>> Bug-Entry =A0 =A0: http://bugzilla.kernel.org/show_bug.cgi?id=3D1=
3018
>>>>> Subject =A0 =A0 =A0 =A0 =A0 =A0 =A0: 2.6.29 on MacBook 2,1 fails =
to reboot
> ...
>>>> The bug _sounds_ like some deadlock due to lock problems - the shu=
tdown
>>>> path often triggers locks that no other path really cares about. A=
nd we
>>>> had some lock problems in the sound subsystem that got fixed post-=
2.6.28,
>>>> for example.
>>>>
>>>> And it looks like the problem is somewhere in sound shutdown:
>>>>
>>>> 12181 delete_module("snd_hda_codec", O_RDONLY|O_EXCL) =3D -1 EAGAI=
N (Resource temporarily unavailable) <0.000011>
>>>>
>>>> So commits like 91054598f794fb5d8a0b1e747ff8e2e8fc2115b3 ("ALSA: p=
cm_oss,
>>>> fix locking typo") might explain it.
> ...
>>> could it be the same as this one?
>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D12321
>>> "System hangs when unloading alsa modules"
>>> http://bugs.gentoo.org/show_bug.cgi?id=3D253535
>>> "System hangs when unloading alsa modules on Kernel >2.6.28"
> ...
>> The first one looks similar, if not identical. =A0The second one
>> doesn't, because my problem happens on 2.6.29 only, not 2.6.28.
>
> The Gentoo bug entry too is about a regression _after_ 2.6.28. :-)
> I.e. 2.6.28.y. are unaffected. =A0It's actually just the downstream
> duplicate of the kernel.org bug entry.
>
>> Either way, the unload problem with the module didn't happen in
>> 2.6.28.
>
> Interdependencies between ALSA modules have changed. =A0The Gentoo in=
it
> scripts attempted to unload them in an order which deadlocked modprob=
e
> due to dependencies. =A0The fix for Gentoo is to just not unload the
> modules on system shutdown. =A0My Gentoo/amd64 Mac mini was affected =
by
> this too; fixed by userland update.
>
> (Added Cc to tiwai-l3A5Bk7waGM@public.gmane.org)
> --
> Stefan Richter
> -=3D=3D=3D=3D=3D-=3D-=3D=3D=3D -=3D-=3D -=3D=3D-=3D
> http://arcgraph.de/sr/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

With the imac(kernel 2.6.29)
/sbin/shutdown -h now   (works)
but
/sbin/reboot
hangs

--=20
Justin P. Mattock
