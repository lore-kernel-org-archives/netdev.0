From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Tue, 4 Aug 2015 18:12:49 +0100
Message-ID: <55C0F291.7060806@citrix.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/08/15 17:41, Jason A. Donenfeld wrote:
> Hi folks,
> 
> Paul McKenney and I had an offline discussion about some rcu questions
> that eventually lead into me investigating a strange full lock-up I'm
> experiencing as a consequence of a printk in softirq inside of an
> rcu_read_lock, when using Xen PV. Relevant excerpts of the
                                ^^  PV guest?

> (gdb) target remote localhost:9999
> Remote debugging using localhost:9999
> __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
> 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  => HVM guest

Which is it?

A HVM guest's serial console may be particularly slow (since it's
emulated by qemu).  Try using the PV console?

David
