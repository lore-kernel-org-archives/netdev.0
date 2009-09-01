From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Mon, 31 Aug 2009 23:33:16 -0400
Message-ID: <1251775996.3345.5.camel@obelisk.thedillows.org>
References: <1251294974.14241.9.camel@obelisk.thedillows.org>
	 <1251295175.14241.11.camel@obelisk.thedillows.org>
	 <m11vmy737x.fsf@fess.ebiederm.org>
	 <20090826213024.GA20428@electric-eye.fr.zoreil.com>
	 <m1hbvu45jq.fsf@fess.ebiederm.org>
	 <20090827052423.GA1709@electric-eye.fr.zoreil.com>
	 <m1ocq1ke9u.fsf@fess.ebiederm.org>
	 <20090827232024.GA30119@electric-eye.fr.zoreil.com>
	 <m1d46gka9e.fsf@fess.ebiederm.org>
	 <1251422978.21865.2.camel@obelisk.thedillows.org>
	 <20090830203735.GA24912@electric-eye.fr.zoreil.com>
	 <m17hwl2fct.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752509AbZIADdV@vger.kernel.org>
In-Reply-To: <m17hwl2fct.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-08-30 at 13:53 -0700, Eric W. Biederman wrote:
> Francois Romieu <romieu@fr.zoreil.com> writes:
> 
> > David Dillow <dave@thedillows.org> :
> > [...]
> >> It'll be this weekend, but I can see cases where it can lock my chip up
> >> -- they should be rare, but then I thought your case would be extremely
> >> rare...
> >
> > I don't get it.
> >
> > Can you elaborate the relevant cases or give some sample scenarios for
> > them ?
> 
> I think David is referring to the fact that in the NAPI loop there is
> nothing that acks everything.

That was my concern, yes.

I've not been able to reproduce my lockups under medium testing with
Francois's patch applied, so I'm a little more comfortable with it.

At the same time, I'm worried that the timing just changed enough to
make it harder to trigger, as was the case when I did the patch IIRC.
The kernel's interrupt handling changed in a manner that made it much
easier to hit about that time. The testing I did in May pointed strongly
at us failing to ACK an interrupt source, causing the MSI generation to
stop, so I need to think about things some more.
