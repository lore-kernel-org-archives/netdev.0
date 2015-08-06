From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Thu, 6 Aug 2015 09:22:49 +0100
Message-ID: <1438849369.9747.91.camel@citrix.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	 <55C0F291.7060806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"Jason A. Donenfeld" <Jason@zx2c4.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C0F291.7060806@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-08-04 at 18:12 +0100, David Vrabel wrote:
> On 04/08/15 17:41, Jason A. Donenfeld wrote:
> > Hi folks,
> > 
> > Paul McKenney and I had an offline discussion about some rcu questions
> > that eventually lead into me investigating a strange full lock-up I'm
> > experiencing as a consequence of a printk in softirq inside of an
> > rcu_read_lock, when using Xen PV. Relevant excerpts of the
>                                 ^^  PV guest?
> 
> > (gdb) target remote localhost:9999
> > Remote debugging using localhost:9999
> > __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
> > 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
>                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  => HVM guest
> 
> Which is it?

Aren't there still some code paths for PV guests which hit the native APIC
case (emulated in Xen even for PV these days, since pvops in the early days
didn't accept the hooks needed to make use of the hypercall versions of
apic read/write).

In particular I'm thinking of the IPI which is (or was) used by the sysrq
to trigger the backtrace on all CPUs.

Ian.
