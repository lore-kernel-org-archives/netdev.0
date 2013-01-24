From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global
 reader-writer lock backend
Date: Thu, 24 Jan 2013 16:58:40 +0100
Message-ID: <20130124155840.GA10651@redhat.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
 <1358883152.21576.55.camel@gandalf.local.home>
 <CANN689HOmiO-5714UiyuOcjrRYW2DkR4cPLgt96f5YeB9Ws3RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org, fweisbec@gmail.com,
 mingo@kernel.org, linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
 xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
 paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
 linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
 Steven Rostedt <rostedt@goodmis.org>, rjw@sisk.pl, namhyung@kernel.org,
 tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, sbw@mit.edu,
 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, tj@kernel.org,
 akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CANN689HOmiO-5714UiyuOcjrRYW2DkR4cPLgt96f5YeB9Ws3RQ@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 01/23, Michel Lespinasse wrote:
>
> On Tue, Jan 22, 2013 at 11:32 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > I thought global locks are now fair. That is, a reader will block if a
> > writer is waiting. Hence, the above should deadlock on the current
> > rwlock_t types.
>
> I believe you are mistaken here. struct rw_semaphore is fair (and
> blocking), but rwlock_t is unfair. The reason we can't easily make
> rwlock_t fair is because tasklist_lock currently depends on the
> rwlock_t unfairness - tasklist_lock readers typically don't disable
> local interrupts, and tasklist_lock may be acquired again from within
> an interrupt, which would deadlock if rwlock_t was fair and a writer
> was queued by the time the interrupt is processed.

Yes.

And, iirc, it was even documented somewhere that while rwlock_t is not
really nice, it is good to share the locking with interrupts. You do
not need to disable irqs.

Oleg.
