From: Dave Airlie <airlied@gmail.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Fri, 4 Feb 2011 10:06:19 +1000
Message-ID: <AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
	<s5haaid3xos.wl%tiwai@suse.de>
	<201102032009.17100.rjw@sisk.pl>
	<AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
	<AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carlos Mafra <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 4, 2011 at 8:10 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Feb 3, 2011 at 1:56 PM, Carlos Mafra <crmafra2@gmail.com> wro=
te:
>>>
>>> I added https://bugzilla.kernel.org/show_bug.cgi?id=3D24982 to the =
list of
>>> post-2.6.36 regressions for further tracking.
>>
>> I also tested on 2.6.38-rc3+ now and the issue is not solved,
>> just like Takashi expected.
>
> Hmm. That commit (bf9dc102e284) still reverts cleanly.
>
> Keith, Dave, should we just revert it? It's definitely a regression,
> and we do _not_ allow "fixes" to one thing that just causes a
> regression to another.
>
> Quite frankly, I think it's totally wrong to just blindly set DPMS
> status to ON like that. It's as wrong as it was to leave it off, and
> the regressions reported are basically mirror images of the exact sam=
e
> bug that that commit tried to fix.
>
> IOW, the commit message says:
>
> =A0 =A0When setting a new crtc configuration, force the DPMS state of=
 all
> =A0 =A0connectors to ON. Otherwise, they'll be left at OFF and a futu=
re mode set
> =A0 =A0that disables the specified connector will not turn the connec=
tor off.
>
> but setting it to ON doesn't actually _fix_ anything, because you jus=
t
> get the exact same issue in reverse, ie you just get
>
> =A0 .. and a future mode set =A0that ENables the specified connector =
will
> =A0 =A0not turn the connector ON.

If we are setting a mode on a connector it automatically will end up
in a DPMS on state,
so this seemed correct from what I can see.

A future mode set shouldn't ever not turn the connector on, since
modesetting is an implicit
DPMS,

It sounds like something more subtle than that, though I'm happy to
revert this for now, and let Keith
think about it a bit more.

Dave.
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
