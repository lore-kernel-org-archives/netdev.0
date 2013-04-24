From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Wed, 24 Apr 2013 11:47:35 +0400
Message-ID: <20130424074735.GB1751@moon>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
 <20130424072630.GB1780@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Lin Ming <ming.m.lin@intel.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130424072630.GB1780@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 24, 2013 at 09:26:30AM +0200, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > And there's quite a lot of them. Even in my (fairly small) config I use on
> > my desktop. And the first warnings I see are in x86 code:
> > 
> >     arch/x86/kernel/traps.c:405:16: warning: implicit unsigned widening
> > cast of a '~' expression
> >     arch/x86/kernel/cpu/perf_event_p4.c:912:15: warning: implicit unsigned
> > widening cast of a '~' expression
> 
> Hm, the perf_event_p4.c code is indeed confused.
> 
> I think the bug is real but probably benign in effect: we allow narrower 
> values into the MSR register than probably intended. Only a couple of low 
> bits are reserved AFAICS.
> 
> Here's an (untested!) patch that tries to untangle it all: it just moves 
> to clean 64-bit types everywhere - these MSRs are 64-bit wide regardless 
> of whether we run on 32-bit or not.
> 
> Would be nice if someone with a working P4 could test it - Cyrill? [It 
> should also be double checked whether the high words are really not 
> reserved and can be written to ...]

Hi Ingo! Ufortunately I don't have access to real p4 hardware,
thus I'm CC'ing Ming who has been helping a lot in testing
this code pieces.

Still the patch itself is perfectly fine to me

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
