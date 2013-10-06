From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 3/8] x86/jump_label: expect default_nop if static_key gets enabled on boot-up
Date: Sun, 6 Oct 2013 02:12:47 +0200
Message-ID: <20131006001247.GB25076@order.stressinduktion.org>
References: <1381015258-7667-1-git-send-email-hannes@stressinduktion.org> <1381015258-7667-4-git-send-email-hannes@stressinduktion.org> <20131005200558.3be2f841@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Jason Baron <jbaron@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, x86@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131005200558.3be2f841@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 05, 2013 at 08:05:58PM -0400, Steven Rostedt wrote:
> >  	if (type == JUMP_LABEL_ENABLE) {
> > -		/*
> > -		 * We are enabling this jump label. If it is not a nop
> > -		 * then something must have gone wrong.
> > -		 */
> > -		if (unlikely(memcmp((void *)entry->code, ideal_nop, 5) != 0))
> > -			bug_at((void *)entry->code, __LINE__);
> > +		if (init) {
> > +			/*
> > +			 * Jump label is enabled for the first time.
> > +			 * So we expect a default_nop...
> > +			 */
> > +			if (unlikely(memcmp((void *)entry->code, default_nop, 5)
> > +				     != 0))
> > +				bug_at((void *)entry->code, __LINE__);
> > +		} else {
> > +			/*
> > +			 * ...otherwise expect an ideal_nop. Otherwise
> > +			 * something went horribly wrong.
> > +			 */
> > +			if (unlikely(memcmp((void *)entry->code, ideal_nop, 5)
> > +				     != 0))
> > +				bug_at((void *)entry->code, __LINE__);
> > +		}
> 
> I don't know if I like this change. This is similar to a bug we had
> with the Xen folks, where they didn't realize that jump labels are not
> suppose to be used (or set) before jump_label_init() is called.
> 
> I'll have to take a deeper look at this on Monday.

Yes, I understand and saw the commit to call jump_label_init
earlier. Maybe the default could be to insert illegal instructions by
default if we try to replace them with nops or branches afterwards anyway.

insn_sanity programs would have to be tought about that, then.

Greetings,

  Hannes
