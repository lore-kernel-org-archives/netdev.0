From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Thu, 6 Aug 2015 11:02:47 +0100
Message-ID: <55C330C7.6050204@citrix.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
 <CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xen.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/15 00:01, Jason A. Donenfeld wrote:
> Hey David,
> 
> Sorry for the premature response on my phone earlier. Real reply follows.
>>> rcu_read_lock, when using Xen PV. Relevant excerpts of the
>>                                 ^^  PV guest?
> 
> Yes. The lockup occurs on a PV guest. Nothing special at all about the
> configuration. Vanilla upstream 4.1.3 kernel.
> 
>>> __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
>>> 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
>>                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  => HVM guest
>>
>> Which is it?
> 
> That's odd. It's a PV guest, not an HVM nor PVH guest.

Linux PV guests must use the "Xen PV" APIC driver.  You need to
investigate why your PV guest is not using this (although I'm surprised
it works at all with the wrong one).

David
