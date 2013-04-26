From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/6] x86: bpf_jit_comp: support
 BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 09:14:00 -0700
Message-ID: <1366992840.8964.239.camel@edumazet-glaptop>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
	 <1366962706-24204-3-git-send-email-xi.wang@gmail.com>
	 <1366985926.8964.190.camel@edumazet-glaptop>
	 <CAKU6vyZfYR-2408G0_Fkp-PS5x5rMH+s4_OOWqqi7Nt+UfiUPg@mail.gmail.com>
	 <1366989094.8964.212.camel@edumazet-glaptop>
	 <CAKU6vyav+4e1RTKnpNRUJ64TO9AJWy2n2yY4rC-PKiqLei0rfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKU6vyav+4e1RTKnpNRUJ64TO9AJWy2n2yY4rC-PKiqLei0rfw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-26 at 12:02 -0400, Xi Wang wrote:
> On Fri, Apr 26, 2013 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 1) 'current' at the time the code is jitted (compiled) is not the
> > 'current' at the time the filter will be evaluated.
> >
> > On x86_64, if CONFIG_IA32_EMULATION=y, syscall_get_arch() evaluates to :
> >
> > if (task_thread_info(task)->status & TS_COMPAT)
> >         return AUDIT_ARCH_I386;
> > return AUDIT_ARCH_X86_64;
> >
> > So your code is completely wrong.
> 
> Just to be clear, are you worrying about a process changing its
> personality after installing seccomp filters?

You didn't explained how things worked.

Are you assuming we network guys know everything ?

Just to make it very clear :

We are very dumb and you must explain us everything.

If process would not change personality, why do we have get_arch() at
all ? Why isn't it optimized outside of the JIT itself, in the generic
seccomp checker, its a single "A = K" instruction after all.

Why this part is even in the x86 BPF JIT ?

To me it looks like _if_ get_arch() is provided in BPF, its for a
reason, and your implementation looks very suspicious, if not buggy.
