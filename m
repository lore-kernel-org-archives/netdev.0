From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH]  hrtimer, softirq: Fix hrtimer->softirq trampoline
Date: Tue, 02 Feb 2010 15:35:50 +0100
Message-ID: <1265121350.24455.309.camel@laptop>
References: <4B66A670.70503@cn.fujitsu.com>
	 <20100202074914.GD11081@gondor.apana.org.au>
	 <20100202085117.7a5c3530@penta.localdomain>
	 <1265120401.24455.306.camel@laptop>
	 <20100202092814.064a89c0@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, polyanskiy@gmail.com,
	Thomas Gleixner <tglx@linutronix.de>,
	lkml <linux-kernel@vger.kernel.org>
To: Yury Polyanskiy <ypolyans@princeton.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100202092814.064a89c0@penta.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-02 at 09:28 -0500, Yury Polyanskiy wrote:
> On Tue, 02 Feb 2010 15:20:01 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> >  static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer *timer)
> >  {
> >  	struct tasklet_hrtimer *ttimer =
> >  		container_of(timer, struct tasklet_hrtimer, timer);
> >  
> > -	if (hrtimer_is_hres_active(timer)) {
> > -		tasklet_hi_schedule(&ttimer->tasklet);
> > -		return HRTIMER_NORESTART;
> > -	}
> > -	return ttimer->function(timer);
> > +	tasklet_hi_schedule(&ttimer->tasklet);
> > +	return HRTIMER_NORESTART;
> >  }
> >  
> 
> Are you totally against if(in_irq())?

Yeah, things like that are an indication that you really don't know wtf
you're doing and are just patching up.

There is a single site where hrtimer callbacks can indeed be done from
softirq, but in that case the above still works correctly, and I've been
meaning to get rid of that anyway.
