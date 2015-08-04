From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Wed, 5 Aug 2015 01:01:25 +0200
Message-ID: <CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, Paul McKenney <paulmck@linux.vnet.ibm.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C0F291.7060806@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey David,

Sorry for the premature response on my phone earlier. Real reply follows.
>> rcu_read_lock, when using Xen PV. Relevant excerpts of the
>                                 ^^  PV guest?

Yes. The lockup occurs on a PV guest. Nothing special at all about the
configuration. Vanilla upstream 4.1.3 kernel.

>> __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
>> 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
>                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  => HVM guest
>
> Which is it?

That's odd. It's a PV guest, not an HVM nor PVH guest.

>
> A HVM guest's serial console may be particularly slow (since it's
> emulated by qemu).  Try using the PV console?

I am using the PV console. But actually the problem occurs too even if
/proc/sys/kernel/printk is set to all zeros (no klog on the console).

The plot thickens?
