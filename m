From: kuznet@ms2.inr.ac.ru
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 04:41:39 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc57g$h3q$2@main.gmane.org>
References: <3CE9960D.15D41380@mvista.com>
Mime-Version: 1.0
Cc: ak@suse.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   davem@redhat.com, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com (george anzinger)
In-Reply-To: <3CE9960D.15D41380@mvista.com> from "george anzinger" at May 20, 2 05:34:21 pm
List-Id: netdev.vger.kernel.org

Hello!

> > if [ "$CONFIG_SMP" = "n" ]; then
> >    bool 'Preemptible Kernel' CONFIG_PREEMPT
> > fi
> > 
> That is not a fix!  It is dodging the issue. ;)

It is the only real fix, if you are going to follow this instruction:

+RULE #1: Per-CPU data structures need explicit protection
+
+
+Two similar problems arise. An example code snippet:
+
+       struct this_needs_locking tux[NR_CPUS];
+       tux[smp_processor_id()] = some_value;
+       /* task is preempted here... */
+       something = tux[smp_processor_id()];
+
+First, since the data is per-CPU, it may not have explicit SMP locking, but
+require it otherwise.  Second, when a preempted task is finally rescheduled,
+the previous value of smp_processor_id may not equal the current.  You must
+protect these situations by disabling preemption around them.

If you are not going to break all the kernel just make sure that
tasks preempted in the kernel do not migrate. That's all, simple & stupid.

Alexey
