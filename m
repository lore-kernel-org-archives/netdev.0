From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global reader-writer lock backend
Date: Mon, 11 Feb 2013 12:41:31 +0000
Message-ID: <30708.1360586491@warthog.procyon.org.uk>
References: <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com> <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, peterz@infradead.org,
	tj@kernel.org, oleg@redhat.com, paulmck@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, mingo@kernel.org, akpm@linux-foundation.org,
	namhyung@kernel.org, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	rjw@sisk.pl, sbw@mit.edu, fweisbec@gmail.com,
	linux@arm.linux.org.uk, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com> wrote:

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

The lock order on CPU 0 is unsafe if CPU2 can do:

	write_lock(&my_rwlock);
	spin_lock(&random_lock);

and on CPU 1 if CPU2 can do:

	spin_lock(&random_lock);
	write_lock(&my_rwlock);

I presume you were specifically excluding these situations?

David
