From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] lglock: add read-preference local-global rwlock
Date: Tue, 5 Mar 2013 17:35:22 +0100
Message-ID: <20130305163522.GA4179@redhat.com>
References: <512CC509.1050000@linux.vnet.ibm.com>
 <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
 <512D0D67.9010609@linux.vnet.ibm.com>
 <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>
 <512E7879.20109@linux.vnet.ibm.com> <5130E8E2.50206@cn.fujitsu.com>
 <20130301182854.GA3631@redhat.com>
 <CANN689HEW=b5S93J27p+rBX-5m7jkW4FER=eHDCp7OgMaTWLPw@mail.gmail.com>
 <20130302170656.GB29769@redhat.com> <51361540.3060603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
 peterz@infradead.org, fweisbec@gmail.com,
 Michel Lespinasse <walken@google.com>, mingo@kernel.org,
 linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
 xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
 paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
 linux-pm@vger.kernel.org, rusty@rustcorp.com.au, rostedt@goodmis.org,
 rjw@sisk.pl, namhyung@kernel.org, tglx@linutronix.de,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, vincent.guittot@linaro.org, sbw@mit.edu,
 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, tj@kernel.org,
 akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <51361540.3060603@cn.fujitsu.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On 03/05, Lai Jiangshan wrote:
>
> On 03/03/13 01:06, Oleg Nesterov wrote:
> > On 03/02, Michel Lespinasse wrote:
> >>
> >> My version would be slower if it needs to take the
> >> slow path in a reentrant way, but I'm not sure it matters either :)
> >
> > I'd say, this doesn't matter at all, simply because this can only happen
> > if we race with the active writer.
>
> It can also happen when interrupted. (still very rarely)
>
> arch_spin_trylock()
> 	------->interrupted,
> 		__this_cpu_read() returns 0.
> 		arch_spin_trylock() fails
> 		slowpath, any nested will be slowpath too.
> 		...
> 		..._read_unlock()
> 	<-------interrupt
> __this_cpu_inc()
> ....

Yes sure. Or it can take the local lock after we already take the global
fallback_lock.

But the same can happen with FALLBACK_BASE, just because we need to take
a lock (local or global) first, then increment the counter.

> (I worries to much. I tend to remove FALLBACK_BASE now, we should
> add it only after we proved we needed it, this part is not proved)

Agreed, great ;)

Oleg.
