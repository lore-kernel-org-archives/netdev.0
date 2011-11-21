From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 14:34:17 -0800
Message-ID: <CALCETrUpXrsjBLZsZU3u+y7KCDO0LW55QoBQkBqN_BPFZHsrkw@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
 <CA+55aFwAELQieN=qR7Gz_MT5rHPp90H10uTMS+DOJjefk7q3ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48216 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333Ab1KUWej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 17:34:39 -0500
In-Reply-To: <CA+55aFwAELQieN=qR7Gz_MT5rHPp90H10uTMS+DOJjefk7q3ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 2:11 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw@sisk.pl> wrot=
e:
>>
>> Subject =A0 =A0: [3.1 REGRESSION] Commit 5cec93c216db77c45f7ce970d46=
283bcb1933884 breaks the Chromium seccomp sandbox
>> Submitter =A0: Nix <nix@esperi.org.uk>
>> Date =A0 =A0 =A0 : 2011-11-14 0:40
>> Message-ID : 8762inleno.fsf@spindle.srvr.nix
>> References : http://marc.info/?l=3Dlinux-kernel&m=3D132123396226377&=
w=3D2
>
> So this should be fixed by commit 2b666859ec32 ("x86: Default to
> vsyscall=3Dnative for now"), since we disabled the vsyscall emulation
> because it broken UML too.

I don't think so.  I think the issue is that the chromium sandbox is
trying to use getcpu, time, or gettimeofday from seccomp mode and the
kernel is (IMO correctly) sending it SIGKILL.  Nix can trigger the bug
in vsyscall=3Dnative mode, so it's not the emulation.  (If it's
gettimeofday, then it's definitely not a regression.  vgettimeofday
would SIGKILL in seccomp mode with any timing source other than rdtsc
or hpet even on old kernels.)

I sent a patch to show which syscall is causing SIGKILL and haven't
heard back.  Meanwhile, I'm downloading the 1.1GB (!) tarball to see
if I can reproduce it here.  Fedora's build didn't trigger it for me,
probably because the sandbox was disabled.

To try to reduce the incidence of this stuff in the future, and to
make vsyscall=3Dnone and UML more useful, I filed this bug:

http://sourceware.org/bugzilla/show_bug.cgi?id=3D13425

--Andy
