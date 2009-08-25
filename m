From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 25 Aug 2009 17:54:56 -0400
Message-ID: <1251237296.9607.42.camel@lap75545.ornl.gov>
References: <200903041828.49972.m.bueker@berlin.de>
 <1242001754.4093.12.camel@obelisk.thedillows.org>
 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
 <1242077392.3716.15.camel@lap75545.ornl.gov> <4A09DC3E.2080807@googlemail.com>
 <1242268709.4979.7.camel@obelisk.thedillows.org>
 <4A0C6504.8000704@googlemail.com>
 <1242328457.32579.12.camel@lap75545.ornl.gov>
 <4A0C7443.1010000@googlemail.com>
 <1243042174.3580.23.camel@obelisk.thedillows.org>
 <m1skfkrik2.fsf@fess.ebiederm.org>
 <1250895567.23419.1.camel@obelisk.thedillows.org>
 <1250897657.23419.5.camel@obelisk.thedillows.org>
 <m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org>
 <1250973787.3582.14.camel@obelisk.thedillows.org>
 <m1r5v0ogvw.fsf@fess.ebiederm.org>
 <1251169150.4023.11.camel@obelisk.thedillows.org>
 <m1ljl77exz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932189AbZHYVy6@vger.kernel.org>
In-reply-to: <m1ljl77exz.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-08-25 at 14:37 -0700, Eric W. Biederman wrote:
> David Dillow <dave@thedillows.org> writes:
> > Here's a possible patch to mask the NAPI events while we're running in
> > NAPI mode. I'm not sure it is going to help, since the intr_mask was
> > 0xffff when you hit the loop guard, so I left it in for now.
> 
> Ok.  I now get what your patch was trying to do and that does look like
> a reasonable test.  
> 
> I prefer:
> while ((status != 0xffff) && (status & tp->intr_mask))

I had thought of going that route first, but if you have any interrupt
event sources set, you want to enter the loop at least once to clear
them, otherwise you never see another MSI interrupt.

If the masking is the way things play out, then I'd put it where I had
it and put in a comment as to why it is there.

> The presence of TxDescUnavail suggests as is usually the case
> that the interrupt status bits are independent of which interrupts
> are actually enabled to fire.

Yes, but I seem to recall the MSI's edge detection being especially
oddly done -- I did tests with various masks and using the ability to
have it generate an interrupt on user demand, and IIRC it was handled
before the mask was applied, so we really did care about the events that
were active -- but I may misremember.

> I will take a moment and give that a try.
> 
> I still like the idea of masking everything having poll do all
> of the work and then unmasking everything.  That seems a little less
> fragile to me.

I wouldn't object if you did it, but I don't have time for it right now.
And it may make Francois's life harder when he does his periodic sweep
of the vendor driver, looking for differences.
