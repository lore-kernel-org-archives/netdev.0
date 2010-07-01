From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 1 Jul 2010 14:07:08 +0300
Message-ID: <20100701110708.GA27368@redhat.com>
References: <4BFEA434.6080405@kernel.org>
 <20100527173207.GA21880@redhat.com>
 <4BFEE216.2070807@kernel.org>
 <20100528150830.GB21880@redhat.com>
 <4BFFE742.2060205@kernel.org>
 <20100530112925.GB27611@redhat.com>
 <4C02C99D.9070204@kernel.org>
 <20100624081135.GA937@redhat.com>
 <1277419551.27868.27.camel@w-sridhar.beaverton.ibm.com>
 <20100625101022.GA16321@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, Tejun Heo <tj@kernel.org>,
	Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100625101022.GA16321@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Author: Sridhar Samudrala <sri@us.ibm.com>

sched: export sched_set/getaffinity to modules

vhost-net driver wants to copy the affinity from the
owner thread to thread it creates. Export
sched_set/get affinity to modules to make this possible
when vhost is built as a module.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

I'm not sure the previous time made it clear what exactly is the
proposed change, so reposting.  Info, Peter, could you ack merging the
following through the net-next tree please?

diff --git a/kernel/sched.c b/kernel/sched.c
index d484081..3759391 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4744,6 +4744,7 @@ out_put_task:
 	put_online_cpus();
 	return retval;
 }
+EXPORT_SYMBOL_GPL(sched_setaffinity);
 
 static int get_user_cpu_mask(unsigned long __user *user_mask_ptr, unsigned len,
 			     struct cpumask *new_mask)
@@ -4807,6 +4808,7 @@ out_unlock:
 
 	return retval;
 }
+EXPORT_SYMBOL_GPL(sched_getaffinity);
 
 /**
  * sys_sched_getaffinity - get the cpu affinity of a process
