From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 17:41:35 -0700
Message-ID: <m14pfgqvk0.fsf@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
	<m11wakshyz.fsf@ebiederm.dsl.xmission.com>
	<20071120215914.GE24156@elte.hu>
	<m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>
	<20071120223559.GA6655@elte.hu>
	<20071120225457.B6E2D26F8BE@magilla.localdomain>
	<20071120230106.GD24380@elte.hu>
	<3d8471ca0711201506t6b2b88a0h9484f8a40a1f2e40@mail.gmail.com>
	<20071120232600.F1D2F26F8BE@magilla.localdomain>
	<47436E7F.2060901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland McGrath <roland@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	Ingo Molnar <mingo@elte.hu>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49482 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765480AbXKUAn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 19:43:29 -0500
In-Reply-To: <47436E7F.2060901@redhat.com> (Ulrich Drepper's message of "Tue,
	20 Nov 2007 15:32:15 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Drepper <drepper@redhat.com> writes:

> Roland McGrath wrote:
>> Oh, it seems it has indeed been that way for a very long time, so I was
>> mistaken.  It still seems a little odd to me.  Ulrich can say definitively
>> whether the kind of concern I mentioned really matters one way or the other
>> for glibc.
>
> glibc cannot survive (at least NPTL) if somebody uses funny CLONE_*
> flags to separate various pieces of information, e.g., file descriptors.
>  So, all the information in each thread's /proc/self should be identical.

Which seems to confirm that glibc and native pthread can't care.

> When the information is not the same, the current semantics seems to be
> more useful.  So I guess, no change is the way to go here.

Could you elaborate a bit on how the semantics of returning the
wrong information are more useful?

In particular if a thread does the logical equivalent of:
grep Pid: /proc/self/status.  It always get the tgid despite
having a different process id.

How can that possibly be useful or correct?

>From the kernel side I really think the current semantics of /proc/self
in the context of threads is a bug and confusing.  All of the kernel
developers first reaction when this was pointed out was that this
is a regression.

If it is truly useful to user space we can preserve this API design
bug forever.  I just want to make certain we are not being bug
compatible without a good reason.

Currently we have several kernel side bugs with threaded
programs because /proc/self does not do the intuitive thing.  Unless
something has changed recently selinux will cause accesses by a
non-leader thread to fail when accessing files through /proc/self.

So far the more I look at the current /proc/self behavior the
more I am convinced it is broken, and useless.  Please help me see
where it is useful, so we can justify keeping it.

Thanks,
Eric
