From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 9 Jul 2010 04:04:42 +0200
Message-ID: <20100709020440.GJ6405@nowhere>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera> <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Dave Airlie <airlied-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2010 at 06:34:25PM -0700, Linus Torvalds wrote:
> On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote=
:
> > Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
16284
> > Subject =A0 =A0 =A0 =A0 : Hitting WARN_ON in hw_breakpoint code
> > Submitter =A0 =A0 =A0 : Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
> > Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-23 12:57 (16 days old)
> > Message-ID =A0 =A0 =A0: <20100623125740.GA3368-oklZEfemRj05kJ7NmlRacFaTQe2KTcn/@public.gmane.org=
>
> > References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277=
29789113432&w=3D2
>=20
> This has "I have a fix, will post it very soon." in the thread from
> Frederic, but I'm not seeing anything else. Frederic?



Right. In fact it wasn't a regression. The per task breakpoint reservat=
ion
design was broken from the beginning and this warning has revealed the
problem. This only touched perf, and it did since perf support breakpoi=
nts.
=46ortunately ptrace wasn't concerned by this problem, even not by side=
 effects
of this.

The fix is invasive as it's a rewrite of a (little) part of the breakpo=
int
reservation. And since the symptom is only a warning and also breakpoin=
ts
never released from the constraint table (just a counter, no memory lea=
k),
the fix is headed for 2.6.36.

It is ready in tip:/perf/core:

http://git.kernel.org/?p=3Dlinux/kernel/git/tip/linux-2.6-tip.git;a=3Dc=
ommitdiff;h=3D45a73372efe4a63f44aa2e1125d4a777c2fdc8d8

I think this ticket can be safely closed.

Thanks.
