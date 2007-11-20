From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 23:35:59 +0100
Message-ID: <20071120223559.GA6655@elte.hu>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m11wakshyz.fsf@ebiederm.dsl.xmission.com> <20071120215914.GE24156@elte.hu> <m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ulrich Drepper <drepper@redhat.com>,
	Roland McGrath <roland@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52555 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbXKTWgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:36:17 -0500
Content-Disposition: inline
In-Reply-To: <m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


these are all questions for Ulrich and Roland - Cc:-ed them.

* Eric W. Biederman <ebiederm@xmission.com> wrote:

> Ingo Molnar <mingo@elte.hu> writes:
> 
> > * Eric W. Biederman <ebiederm@xmission.com> wrote:
> >
> >> > lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net
> >> > ...
> >> 
> >> Yes all of those are nasty.  So much for my clever way of implementing 
> >> these things.  Grr. Simple hacks that almost work!
> >
> > btw., in case you feel inclined, i recently did some userspace coding 
> > and found to my surprise that /proc/self points to the parent task, not 
> > the thread itself (giving threads no real way to examine themselves). If 
> > you are hacking in this area, would it be a big trouble to add something 
> > like /proc/self-task/ or something like that? I had to use a raw gettid 
> > syscall to figure out the TID to get to /proc/*/tasks/TID/sched 
> > instrumentation info - which is quite a PITA.
> 
> Agreed.  I have been debating with myself in the last couple of days 
> if it is a bug that /proc/self uses the tgid and not the actual 
> pid/tid value.
> 
> If I can be convinced that posix threads don't care I will happily 
> just switch /proc/self, calling the current implementation a bug.
> 
> I think it is a bug the real question is what are the backwards 
> compatibility implications.  Do posix threads care?
> 
> It appears to me that either we need to fix /proc/self or we need to 
> add /proc/task-self and fix /proc/mounts to point at that.
> 
> In the normal case we share all of the same things so I think it is a 
> don't care.  Except that /proc/self/status | grep Pid returns the 
> tgid.
> 
> Hmm.  I think I am just going to send Andrew a patch for 2.6.25 that 
> just fixes /proc/self.  I just fail to see how using the tgid is 
> correct. The only cases we could care seem to do the wrong thing when 
> we use the tgid.

