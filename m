From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global
 reader-writer lock backend
Date: Tue, 22 Jan 2013 14:32:32 -0500
Message-ID: <1358883152.21576.55.camel@gandalf.local.home>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	 <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	rjw@sisk.pl, sbw@mit.edu, fweisbec@gmail.com,
	linux@arm.linux.org.uk, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-22 at 13:03 +0530, Srivatsa S. Bhat wrote:
> A straight-forward (and obvious) algorithm to implement Per-CPU Reader-Writer
> locks can also lead to too many deadlock possibilities which can make it very
> hard/impossible to use. This is explained in the example below, which helps
> justify the need for a different algorithm to implement flexible Per-CPU
> Reader-Writer locks.
> 
> We can use global rwlocks as shown below safely, without fear of deadlocks:
> 
> Readers:
> 
>          CPU 0                                CPU 1
>          ------                               ------
> 
> 1.    spin_lock(&random_lock);             read_lock(&my_rwlock);
> 
> 
> 2.    read_lock(&my_rwlock);               spin_lock(&random_lock);
> 
> 
> Writer:
> 
>          CPU 2:
>          ------
> 
>        write_lock(&my_rwlock);
> 

I thought global locks are now fair. That is, a reader will block if a
writer is waiting. Hence, the above should deadlock on the current
rwlock_t types.

We need to fix those locations (or better yet, remove all rwlocks ;-)

-- Steve
