From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] lglock: add read-preference local-global rwlock
Date: Sat, 2 Mar 2013 18:01:45 +0100
Message-ID: <20130302170145.GA29769@redhat.com>
References: <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com> <512E7879.20109@linux.vnet.ibm.com> <5130E8E2.50206@cn.fujitsu.com> <20130301182854.GA3631@redhat.com> <513201B7.5070004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Lai Jiangshan <eag0628@gmail.com>,
	Michel Lespinasse <walken@google.com>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	namhyung@kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, vincent.guittot@linaro.org,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <513201B7.5070004@cn.fujitsu.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02, Lai Jiangshan wrote:
>
> On 02/03/13 02:28, Oleg Nesterov wrote:
> > Lai, I didn't read this discussion except the code posted by Michel.
> > I'll try to read this patch carefully later, but I'd like to ask
> > a couple of questions.
> >
> > This version looks more complex than Michel's, why? Just curious, I
> > am trying to understand what I missed. See
> > http://marc.info/?l=linux-kernel&m=136196350213593
>
> Michel changed my old draft version a little, his version is good enough for me.

Yes, I see. But imho Michel suggested the valuable cleanup, the code
becomes even more simple with the same perfomance.

Your v2 looks almost correct to me, but I still think it makes sense
to incorporate the simplification from Michel.

> My new version tries to add a little better nestable support with only
> adding single __this_cpu_op() in _read_[un]lock().

How? Afaics with or without FALLBACK_BASE you need _reed + _inc/dec in
_read_lock/unlock.

Oleg.

